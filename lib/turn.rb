module Turn
  # Returns +true+ if the ruby version supports minitest.
  # Otherwise, +false+ is returned.
  def self.minitest?
    RUBY_VERSION >= '1.9'
  end
end

unless defined?(Turn::Command)
  if Turn.minitest?
    require 'turn/autorun/minitest'
    MiniTest::Unit.autorun
  else
    require 'turn/autorun/testunit'
  end
  #autoload :Test,     'turn/autorun/testunit'
  #autoload :MiniTest, 'turn/autorun/minitest'
end

