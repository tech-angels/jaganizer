module Jaganizer
  module Controllers
    class Chatroom < ActionController::Base
      protect_from_forgery :except => :auth
      before_filter :get_user_infos

      def auth
        response = Jaganizer.request('jaganizer_auth',
                                    { :channel_name => params[:channel_name],
                                      :socket_id    => params[:socket_id],
                                      :user_id      => @user_id,
                                      :user_info    => @user })

        handle_http_response(response.code.to_i, lambda { render :json => response.body })
      end

      def talk
        response = Jaganizer.request('jaganizer_talk',
                                    { :channel_name => params[:channel_name],
                                      :user_id      => @user_id,
                                      :user_info    => @user,
                                      :message      => params[:message] })

        handle_http_response(response.code.to_i, lambda { render :json => response.body })
      end

      def load_logs
        response = Jaganizer.request("jaganizer_logs/#{params[:channel_name]}")
        
        handle_http_response(response.code.to_i, lambda { render :json => response.body })
      end

      def update_message
        response = Jaganizer.request('jaganizer_update',
                                    { :message_id => params[:message_id],
                                      :user_id    => @user_id,
                                      :message    => params[:updated_message] })

        handle_http_response(response.code.to_i, lambda { render :json => response.body })
      end

      protected

      def get_user_infos
        session[:userid] ||= Time.now.to_i
        @user_id = session[:userid]
        @user = {
          :username => "User #{@user_id}",
          :avatar => "http://placekitten.com/30/30",
          :details => "Your details"
        }
      end

      private

      def handle_http_response(response_code, render_code)
        if response_code / 100 == 2
          render_code.call
        else
          head response_code
        end
      end
    end
  end
end