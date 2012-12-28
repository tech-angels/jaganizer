# require everything from jaganizer dir
Dir[File.dirname(__FILE__) + '/jaganizer/**/*.rb'].each {|file| require file.split(/\.rb$/).first }

module Jaganizer
  def self.request(path, params = {})
    connection = Connection.new

    if params.empty?
      connection.get(path)
    else
      connection.post(path, params)
    end
  end
end
