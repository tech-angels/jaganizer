require 'jaganizer/view_helpers'

module Jaganizer
  class Railtie < Rails::Railtie
    initializer "jaganizer.view_helpers" do
      ActionView::Base.send :include, ViewHelpers
    end
  end
end