module Jaganizer
  def self.config
    begin
       @config ||= YAML.load_file(config_file).with_indifferent_access[Rails.env]
    rescue Exception => e
      raise "Error occured when trying to read config/jaganizer.yml\n#{e}"
    end
  end

  def self.config_file
    File.join(Rails.root,'config','jaganizer.yml')
  end
end