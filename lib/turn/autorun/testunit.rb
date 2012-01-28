require 'turn/testunit'

Test::Unit::AutoRunner::RUNNERS[:console] = proc do |r|
  Turn::TestRunner
end

Test::Unit.run = true

