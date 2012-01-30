require 'turn'

if Turn.testunit?
  Test::Unit.run = true
else
  MiniTest::Unit.autorun
end

