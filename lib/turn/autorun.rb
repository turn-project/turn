require 'turn/autoload'

if Turn.minitest?
  require 'turn/autorun/minitest'
  MiniTest::Unit.autorun
else
  require 'turn/autorun/testunit'
end

