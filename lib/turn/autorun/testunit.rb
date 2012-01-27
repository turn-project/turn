#require 'test/unit/ui/console/testrunner'
require 'turn/autoload_trick'

require 'turn/colorize'
require 'turn/controller'
require 'turn/runners/testrunner'

Test::Unit::AutoRunner::RUNNERS[:console] = proc do |r|
  Turn::TestRunner
end
