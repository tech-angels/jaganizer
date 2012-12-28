require 'spec_helper'
describe ChatroomsController do
  before :each do
    simulate_jagan_responses
  end

  describe "POST 'pusher_auth'" do
    context 'with correct mandatory params' do
      before :each do
        post "auth", :socket_id => "206406c7-55cf-4a30-b5f8-72940e8c99c3", :channel_name => "presence-test"
      end

      it "send a request to Jagan" do
        WebMock.should have_requested(:post, jaganizer_url_for('jaganizer_auth'))
                  .with(:body => body_regexp_for('auth'), :headers => {'Content-Type'=>'application/json'}).once
      end

      it 'renders a valid json' do
        response.header['Content-Type'].should include 'application/json'
        body = JSON.parse(response.body)

        body.should have_key('auth')
        body.should have_key('channel_data')
        channel_data = JSON.parse(body['channel_data'])
        channel_data.should have_key('user_id')
      end
    end

    context 'with missing mandatory params' do
      it 'renders 400 HTTP error' do
        post "auth", :channel_name => "presence-test"
        response.status.should == 400
      end
    end
  end

  describe "POST 'talk'" do
    context 'with correct mandatory params' do
      before :each do
        # Have to specify channel_name because session's not kept between test
        post "talk", :message => "Message from controller spec", :channel_name => "presence-test"
      end

      it "send a request to Jagan" do
        WebMock.should have_requested(:post, jaganizer_url_for('jaganizer_talk'))
                  .with(:body => body_regexp_for('talk'), :headers => {'Content-Type'=>'application/json'}).once
      end

      it 'renders a valid JSON message' do
        response.header['Content-Type'].should include 'application/json'
        body = JSON.parse(response.body)

        body.should have_key('id')
        body.should have_key('content')
        body.should have_key('timestamp')
      end
    end

    context 'with empty message' do
      it 'renders 400 HTTP error' do
        post "talk", :message => "", :channel_name => "presence-test"
        response.status.should == 400
      end
    end

    context 'with missing message parameter' do
      it 'renders 400 HTTP error' do
        post "talk", :channel_name => "presence-test"
        response.status.should == 400
      end
    end
  end

  describe "GET 'logs'" do
    before :each do
      get "load_logs", :channel_name => "presence-chatroom"
    end

    it 'sends a request to Jagan' do
      WebMock.should have_requested(:get, jaganizer_url_for("jaganizer_logs/presence-chatroom")).once
    end

    it 'renders a valid logs JSON' do
      response.header['Content-Type'].should include 'application/json'
      body = JSON.parse(response.body)

      body.each do |message|
        message.should have_key('id')
        message.should have_key('user_id')
        message.should have_key('user_info')
        message.should have_key('message')
        message.should have_key('timestamp')
      end
    end
  end

  describe "POST 'update_message'" do
    before :each do
      post "update_message", :message_id => 123456789, :updated_message => "My updated message"
    end

    it 'sends a request to Jagan' do
      WebMock.should have_requested(:post, jaganizer_url_for('jaganizer_update'))
                .with(:body => body_regexp_for('update'), :headers => {'Content-Type'=>'application/json'}).once
    end

    it 'renders a valid JSON message' do
      response.header['Content-Type'].should include 'application/json'
      body = JSON.parse(response.body)

      body.should have_key('id')
      body.should have_key('content')
      body.should have_key('timestamp')
    end
  end
end