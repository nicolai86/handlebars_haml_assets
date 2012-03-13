require "handlebars_haml_assets/version"
require "handlebars_haml_assets/handlebars_input_helper"
require "handlebars_haml_assets/haml_assets"

module HandlebarsHamlAssets
  PATH = File.expand_path("../../vendor/assets/javascripts", __FILE__)

  def self.path
    PATH
  end

  class Railtie < ::Rails::Railtie
  end
end
