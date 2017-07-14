require 'opal'
require 'js'
require 'console'
require 'browser'
require 'bowser'
require 'power_strip'
require 'pp'

def Object.pp_log(var)
  $console.log(var)
end

require 'virtual_dom'
require 'molecule/component/virtual_dom'
require 'molecule/component/render'
require 'molecule/component/cache'
require 'molecule/component/class_methods'
require 'molecule/injection'
require 'molecule/component'
require 'molecule/browser'
require 'molecule/routes'
require 'molecule/router'
require 'molecule/power_cable'



# Main Molecule module
module Molecule; end