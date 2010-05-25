
autoload :Test,     'turn/autorun/testunit'
autoload :MiniTest, 'turn/autorun/minitest'

module Turn

  # Returns +true+ if the ruby version supports minitest. Otherwise, +false+
  # is returned.
  #
  def self.minitest?
    RUBY_VERSION >= '1.9'
  end

end  # module Turn

