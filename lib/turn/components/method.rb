module Turn

  #
  class TestMethod
    attr_accessor :name
    attr_accessor :file
    attr_accessor :message

    def initialize(name)
      @name    = name
      @fail    = false
      @error   = false
      @message = nil
    end

    def fail!(message=nil)
      @fail, @error = true, false
      @message = message if message
    end

    def error!(message=nil)
      @fail, @error = false, true
      @message = message if message
    end

    def fail?  ; @fail  ; end
    def error? ; @error ; end
    def pass?  ; !(@fail or @error) ; end
  end

end

