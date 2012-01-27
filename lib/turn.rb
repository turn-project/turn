module Turn
  # Returns +true+ if the ruby version supports minitest.
  # Otherwise, +false+ is returned.
  def self.minitest?
    RUBY_VERSION >= '1.9'
  end
end

#require 'turn/autoload'

# TODO: Remove autorun in turn.rb for v1.0.
unless defined?(Turn::Command)
  warn "Use `require 'turn/autorun'` instead of `require 'turn'` for future versions."
  if Turn.minitest?
    require 'turn/autorun/minitest'
    MiniTest::Unit.autorun
  else
    require 'turn/autorun/testunit'
  end
end

