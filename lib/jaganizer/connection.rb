require 'net/https'

module Jaganizer
  class Connection
    def initialize
      @connection = Net::HTTP.new(Jaganizer.config[:site], 80)
      @connection.use_ssl = false
    end

    def post(path, params)
      request = Net::HTTP::Post.new("/apps/#{Jaganizer.config[:app_id]}/#{path}", {'Content-Type' =>'application/json'})
      request.basic_auth(Jaganizer.config[:app_id], Jaganizer.config[:secret])
      request.body = params.to_json

      @connection.request(request)
    end

    def get(path)
      request = Net::HTTP::Get.new("/apps/#{Jaganizer.config[:app_id]}/#{path}")
      request.basic_auth(Jaganizer.config[:app_id], Jaganizer.config[:secret])

      @connection.request(request)
    end
  end
end