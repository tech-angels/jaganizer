require "hmac-sha2"

def jaganizer_url_for(path)
  "http://#{Jaganizer.config[:app_id]}:#{Jaganizer.config[:secret]}@#{Jaganizer.config[:site]}/apps/#{Jaganizer.config[:app_id]}/#{path}"
end

def body_regexp_for(request_type)
  case request_type
  when 'auth'
    /\{ "channel_name": "[^"]+",
        "socket_id"   : "[^"]+",
        "user_id"     :  [^,"]+,
        "user_info"   : \{ ("(username|avatar|details)" : "[^"]+",?)* \} \}/x
  when 'incomplete_auth'
    /\{ "channel_name": "[^"]+",
        "socket_id"   : null,
        "user_id"     :  [^,"]+,
        "user_info"   : \{ ("(username|avatar|details)" : "[^"]+",?)* \} \}/x
  when 'talk'
    /\{ "channel_name" : "[^"]+", "user_id" : [^,"]+, "user_info" : \{ ("(username|avatar|details)" : "[^"]+",?)* \}, "message" : ".+"\}/x
  when 'invalid_talk'
    /\{ "channel_name" : "[^"]+", "user_id" : [^,"]+, "user_info" : \{ ("(username|avatar|details)" : "[^"]+",?)* \}, "message" : ("" | null)\}/x  
  when 'update'
    /\{ "message_id" : "[^"]+", "user_id" : [^,"]+, "message" : ".+" \}/x
  else
    /\{.+\}/
  end
end

def simulate_jagan_responses
  # Test POST request
  stub_request(:post, jaganizer_url_for('test'))
    .with(:body => '{"param1":"param1","param2":2}',
          :headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'})

  # Test GET request
  stub_request(:get, jaganizer_url_for('test'))
    .with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'})

  # Correct Pusher subscription
  stub_request(:post, jaganizer_url_for('jaganizer_auth'))
    .with(:body => body_regexp_for('auth'),
          :headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'})
    .to_return do |request|
      # Get a valid signature
      request_body = JSON.parse(request.body)
      json_user_data = JSON.generate({
        :user_id => request_body['user_id'],
        :user_info => request_body['user_info']
      })
      string_to_sign = request_body['socket_id'] + ':' + request_body['channel_name'] + ':' + json_user_data
      signature = HMAC::SHA256.hexdigest(Jaganizer.config[:secret], string_to_sign)

      {
        :status => 200,
        :body => JSON.generate({
          :auth => "#{Jaganizer.config[:key]}:#{signature}",
          :channel_data => json_user_data
        }),
        :headers => { 'Content-Type'=>'application/json' }
      }
    end

  # Incomplete Pusher subscription
  stub_request(:post, jaganizer_url_for('jaganizer_auth'))
    .with(:body => body_regexp_for('incomplete_auth'),
          :headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'})
    .to_return(:status => 400, :body => 'Missing parameters')

  # Correct Pusher talk
  stub_request(:post, jaganizer_url_for('jaganizer_talk'))
    .with(:body => body_regexp_for('talk'),
          :headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'})
    .to_return do |request|
      request_body = JSON.parse(request.body)
      {
        :status => 200,
        :body   => JSON.generate({
          :id         => '123456789',
          :content    => request_body['message'],
          :timestamp  => Time.now.to_i
        }),
        :headers => { 'Content-Type'=>'application/json' }
      }
    end

  # Invalid Pusher talk
  stub_request(:post, jaganizer_url_for('jaganizer_talk'))
    .with(:body => body_regexp_for('invalid_talk'),
          :headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'})
    .to_return(:status => 400, :body => 'Missing parameters')

  # Get Logs
  stub_request(:get, jaganizer_url_for('jaganizer_logs/presence-chatroom'))
    .with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'})
    .to_return(:status => 200,
              :body => generate_logs_json(10),
              :headers => { 'Content-Type'=>'application/json' })

  # Update request
  stub_request(:post, jaganizer_url_for('jaganizer_update'))
    .with(:body => body_regexp_for('update'),
          :headers => {'Accept'=>'*/*', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'})
    .to_return do |request|
      request_body = JSON.parse(request.body)
      {
        :status => 200,
        :body   => JSON.generate({
          :id         => '987654321',
          :content    => request_body['message'],
          :timestamp  => Time.now.to_i
        }),
        :headers => { 'Content-Type'=>'application/json' }
      }
    end
end

def generate_logs_json(number)
  messages = []
  number.times do
    messages << {
      :id         => rand(100),
      :user_id    => Time.now.to_i,
      :timestamp  => (Time.now - 1.day).to_i,
      :user_info  => {:username => "Stubbed username"},
      :message    => "test message"
    }
  end

  JSON.generate(messages)
end