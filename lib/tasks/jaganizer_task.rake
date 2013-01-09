namespace :jaganizer do
  task :init => ['copy_config_file', 'init_pusher_submodule']

  desc "Create config/jaganizer.yml from config/jaganizer.yml.example"
  task :copy_config_file do
    FileUtils.cp 'spec/dummy/config/jaganizer.yml.example', 'spec/dummy/config/jaganizer.yml'
  end

  desc "Initialize pusher-test submodule"
  task :init_pusher_submodule do
    system "git submodule init"
    system "git submodule update"
    system "cd spec/dummy/public/pusher-test-stub && git checkout -b presence-channels origin/presence-channels && git pull && cd ./../../.."
  end
end