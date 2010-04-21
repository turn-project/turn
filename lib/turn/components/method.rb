module Turn

  #
  class TestMethod
    attr_accessor :name
    attr_accessor :file
    attr_accessor :raised
    attr_accessor :message

    def initialize(name)
      @name    = name
      @fail    = false
      @error   = false
      @raised  = nil
      @message = nil
    end

    def fail!(assertion)
      @fail, @error = true, false
      @rasied  = assertion
      @message = assertion.message
    end

    def error!(exception)
      @fail, @error = false, true
      @rasied  = exception
      @message = exception.message
    end

    def fail?  ; @fail  ; end
    def error? ; @error ; end
    def pass?  ; !(@fail or @error) ; end
  end

end

