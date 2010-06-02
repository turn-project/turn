module Turn

  #
  class TestMethod
    attr_accessor :name
    attr_accessor :file
    attr_accessor :raised
    attr_accessor :message
    attr_accessor :backtrace

    def initialize(name)
      @name      = name
      @fail      = false
      @error     = false
      @raised    = nil
      @message   = nil
      @backtrace = []
    end

    def fail!(assertion)
      @fail, @error = true, false
      @rasied    = assertion
      @message   = assertion.message
      @backtrace = assertion.backtrace
    end

    def error!(exception)
      @fail, @error = false, true
      @rasied    = exception
      @message   = exception.message
      @backtrace = exception.backtrace
    end

    def fail?  ; @fail  ; end
    def error? ; @error ; end
    def pass?  ; !(@fail or @error) ; end

    def to_s ; name ; end
  end

end

