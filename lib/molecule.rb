require 'opal'
require 'opal-browser'
require 'opal-jquery'
require 'opal-activesupport'
require 'bowser'
require 'power_strip'
require 'active_interaction'
Opal.append_path File.expand_path('../../opal', __FILE__)

require 'molecule/config'

module Molecule
  # Molecule engine for rails
  class Engine < ::Rails::Engine
    config.assets.paths << File.expand_path('../../opal', __FILE__)
    config.assets.paths << File.expand_path('../../app/assets', __FILE__)
    initializer 'molecule.load_app_root' do |app|
      config.assets.paths << app.root.join('app', 'components')
      config.assets.paths << app.root.join('app', 'packages')
      config.assets.paths << app.root.join('app', 'assets', 'vendor')
      paths = [app.root.join('app', 'components'),
               app.root.join('app', 'packages'),
               File.expand_path('../', __FILE__)]
      paths.each do |path|
        ActiveSupport::Dependencies.autoload_paths << path
      end
      PowerStrip.start
    end
  end
end
