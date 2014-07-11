module Turn
  # Use by the command line tool to start test run.
  def self.run
    $turn_command = true
    Minitest.autorun
  end
end

require 'fileutils'

require 'turn/version'
require 'turn/autoload'
require 'turn/configuration'
require 'turn/colorize'
require 'turn/components'
require 'turn/controller'
require 'turn/command'

require 'turn/minitest'

