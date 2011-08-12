require 'turn/autoload'

require 'minitest/unit'
require 'minitest/spec'

require 'turn/colorize'
require 'turn/controller'
require 'turn/runners/minirunner'

if MiniTest::Unit.respond_to?(:runner=)
  MiniTest::Unit.runner = Turn::MiniRunner.new
else
  raise "MiniTest v#{MiniTest::Unit::VERSION} is out of date.\n" \
        "`gem install minitest` and add `gem 'minitest' to you test helper."
  #MiniTest::Unit = Turn::MiniRunner
end

