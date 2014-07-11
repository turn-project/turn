# make sure latest verison is used, rather than ruby's built-in
begin
  gem 'minitest' #, '>= 5.0.0'
rescue Gem::LoadError
  warn "gem install minitest"
end

# we save the developer the trouble of having to load these (TODO: should we?)
#require 'minitest/unit'
require 'minitest/spec'

# set MiniTest's runner to Turn::MiniRunner instance
if MiniTest::Unit.respond_to?(:runner=)
  # load Turn's minitest runner
  require 'turn/runners/minirunner'
  MiniTest::Unit.runner = Turn::MiniRunner.new
  #MiniTest::Unit = Turn::MiniRunner
else
  require 'turn/adapter'
end

