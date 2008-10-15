require 'yaml'

module Turn
  require 'turn/reporter'

  # = Marshal Reporter
  #
  class MarshalReporter < Reporter

    #def start_suite(suite)
    #  #@suite = suite
    #  #@time  = Time.now
    #  #files = suite.collect{ |s| s.file }.join(' ')
    #  #io.puts "Loaded suite #{suite.name}"
    #  #io.puts "Started"
    #end

    #def start_test(test)
    #  #if @file != test.file
    #  #  @file = test.file
    #  #  io.puts(test.file)
    #  #end
    #  io.print "    %-69s" % test.name
    #end

    #def start_case(kase)
    #  io.puts(kase.name)
    #end

    #def pass(message=nil)
    #  io.puts " #{PASS}"
    #  if message
    #    message = ::ANSICode.magenta(message) if COLORIZE
    #    io.puts(message.to_s)
    #  end
    #end

    #def fail(message=nil)
    #  io.puts(" #{FAIL}")
    #  if message
    #    message = ::ANSICode.magenta(message) if COLORIZE
    #    io.puts(message.to_s)
    #  end
    #end

    #def error(message=nil)
    #  io.puts("#{ERROR}")
    #  io.puts(message.to_s) if message
    #end

    #def finish_test(test)
    #end

    #def finish_case(kase)
    #end

    def finish_suite(suite)    
      $stdout << suite.to_yaml
    end

  end

end

