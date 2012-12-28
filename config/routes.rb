Rails.application.routes.draw do
  post  'jaganizer_auth'    => 'chatrooms#auth'
  post  'jaganizer_talk'    => 'chatrooms#talk'
  get   'jaganizer_logs'    => 'chatrooms#load_logs'
  post   'jaganizer_update' => 'chatrooms#update_message'
end