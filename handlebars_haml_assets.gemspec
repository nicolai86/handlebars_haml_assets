# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "handlebars_haml_assets/version"

Gem::Specification.new do |s|
  s.name        = "handlebars_haml_assets"
  s.version     = HandlebarsHamlAssets::VERSION
  s.authors     = ["Raphael Randschau"]
  s.email       = ["nicolai86@me.com"]
  s.homepage    = ""
  s.summary     = %q{Include automatic attribute-binding to form_for}
  s.description = %q{Include automatic attribute-binding to form_for}

  s.rubyforge_project = "handlebars_haml_assets"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "tilt"

  s.add_development_dependency 'rails', '~> 3.1.0'
  s.add_development_dependency "rspec"
end
