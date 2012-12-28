class ChatroomsController < Jaganizer::Controllers::Chatroom
  def get_user_infos
    session[:userid] ||= Time.now.to_i
    @user_id = session[:userid]
    @user = {
      :username => "User #{@user_id}",
      :avatar => "http://placekitten.com/30/30",
      :details => "Your details from dummy app"
    }
  end
end