# make sure latest verison is used, rather than ruby's built-in
begin
  gem 'minitest', '< 5.0.0'
rescue Exception
  warn "gem install minitest"
end

# we save the developer the trouble of having to load these (TODO: should we?)
require 'minitest/unit'
require 'minitest/spec'

# compatability with old Test::Unit
#Test = MiniTest unless defined?(Test)

# load Turn's minitest runner
require 'turn/runners/minirunner'

# set MiniTest's runner to Turn::MiniRunner instance
if MiniTest::Unit.respond_to?(:runner=)
  MiniTest::Unit.runner = Turn::MiniRunner.new
else
  raise "MiniTest v#{MiniTest::Unit::VERSION} is out of date.\n" \
        "Please update to a newer version, but version 5.0.0 or above will not work. ."
  #MiniTest::Unit = Turn::MiniRunner
end
