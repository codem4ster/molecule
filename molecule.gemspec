$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require 'molecule/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'molecule'
  s.version     = Molecule::VERSION
  s.authors     = ['cm']
  s.email       = ['onurelibol@gmail.com']
  s.homepage    = 'http://moleculegem.com'
  s.summary     = 'Another try of isomorphic ruby frontend library'
  s.description = 'Another try of isomorphic ruby frontend library'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'rails', '~> 5.1.2'
  s.add_dependency 'opal-rails'
  s.add_dependency 'opal-virtual-dom', '~> 0.5.0'
  s.add_dependency 'opal-browser'
  s.add_dependency 'active_interaction'
  s.add_dependency 'power_strip'
  s.add_dependency 'grand_central'
  s.add_dependency 'redis'
  s.add_dependency 'bowser'

  s.add_development_dependency 'bundler', '~> 1.0'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'opal-rspec', '~> 0.6.0.beta'
end
