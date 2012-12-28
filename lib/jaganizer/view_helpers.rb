module Jaganizer
  module ViewHelpers
    def jaganizer_widget(channel_name = 'jaganizer_chatroom')
      raise "invalid channel_name" unless channel_name =~ /^[\w=-@,\.;]+$/
      @channel_name = "presence-#{channel_name}"
      render 'jaganizer/widget'
    end
  end
end