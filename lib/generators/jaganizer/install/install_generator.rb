module Jaganizer
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Installs jaganizer and generates configuration file"

      def self.source_root
         @_jaganizer_source_root ||= File.expand_path("../templates", __FILE__)
      end

      def copy_example_config
        copy_file 'jaganizer.yml.example', 'config/jaganizer.yml.example'
      end
    end
  end
end