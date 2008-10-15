require 'turn/reporter'

module Turn

  # = Traditional Dot Reporter
  #
  class DotReporter < Reporter

    def start_testsuite(suite, size=suite.size)
      @time = Time.now
      files = suite.collect{ |s| s.file }.join(' ')
      io.puts "Loaded suite #{files}"
      io.puts "Started"
    end

    def start_testcase
    end

    def start_test
    end

    def pass
      io.print '.'; io.flush
    end

    def fail
      io.print 'F'; io.flush
    end

    def error
      io.print 'E'; io.flush
    end

    def finish_test
    end

    def finish_testcase
    end

    def finish_testsuite
      io.puts("Finished in %.5d seconds." % [Time.now - @time])
    end

  end

end
