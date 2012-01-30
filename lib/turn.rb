#
module Turn
  # Are we using Test::Unit (1.x)?
  def self.testunit?
    defined?(Test::Unit) && !defined?(MiniTest)
  end
end

require 'fileutils'

require 'turn/version'
require 'turn/autoload'
require 'turn/configuration'
require 'turn/colorize'
require 'turn/components'
require 'turn/controller'

if Turn.testunit?
  require 'turn/testunit'
else
  require 'turn/minitest'
end

#if ENV['autorun']
#  warn "Use `require 'turn/autorun'` instead of `require 'turn'` for future versions."
#  MiniTest::Unit.autorun
#end

