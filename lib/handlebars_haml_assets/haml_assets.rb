module HamlAssets
  class HamlSprocketsEngine < ::Tilt::Template
    module ViewContext
      include HandlebarsInputHelper
    end
  end
end