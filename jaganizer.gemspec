$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "jaganizer/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "jaganizer"
  s.version     = Jaganizer::VERSION
  s.authors     = ["Tech-Angels"]
  s.email       = ["contact@tech-angels.com"]
  s.homepage    = "http://tech-angels.com"
  s.summary     = "Jagan chat widget"
  s.description = "This gem adds a chat widget to your website."

  s.files = Dir["{app,config,db,lib, vendor}/**/*"] + ["Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 3.2.9"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'capybara-webkit'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'ruby-hmac'
end
