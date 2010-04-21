require 'turn/reporter'

module Turn

  # = Outline Reporter (Turn's Original)
  #
  #--
  # TODO: Should we fit reporter output to width of console?
  # TODO: Running percentages?
  #++
  class OutlineReporter < Reporter

    def start_suite(suite)
      @suite = suite
      @time  = Time.now
      @stdout = StringIO.new
      @stderr = StringIO.new
      #files = suite.collect{ |s| s.file }.join(' ')
      io.puts "Loaded suite #{suite.name}"
      #io.puts "Started"
    end

    def start_case(kase)
      io.puts(kase.name)
    end

    def start_test(test)
      #if @file != test.file
      #  @file = test.file
      #  io.puts(test.file)
      #end
      io.print "    %-69s" % test.name
      $stdout = @stdout
      $stderr = @stderr
      $stdout.rewind
      $stderr.rewind
    end

    def pass(message=nil)
      io.puts " #{PASS}"
      if message
        message = ::ANSI::Code.magenta(message) if COLORIZE
        message = message.to_s.tabto(8)
        io.puts(message)
      end
    end

    def fail(assertion)
      io.puts(" #{FAIL}")
      #message = assertion.location[0] + "\n" + assertion.message #.gsub("\n","\n")
      message = assertion.to_s
      #if message
        message = ::ANSI::Code.magenta(message) if COLORIZE
        message = message.to_s.tabto(8)
        io.puts(message)
      #end
      show_captured_output
    end

    def error(exception)
      #message = exception.to_s.split("\n")[2..-1].join("\n")
      message = exception.to_s
      io.puts("#{ERROR}")
      io.puts(message) #if message
    end

    def finish_test(test)
      $stdout = STDOUT
      $stderr = STDERR
    end

    def show_captured_output
      show_captured_stdout
      show_captured_stderr
    end

    def show_captured_stdout
      @stdout.rewind
      return if @stdout.eof?
      STDOUT.puts(<<-output.tabto(8))
\nSTDOUT:
#{@stdout.read}
      output
    end

    def show_captured_stderr
      @stderr.rewind
      return if @stderr.eof?
      STDOUT.puts(<<-output.tabto(8))
\nSTDERR:
#{@stderr.read}
      output
    end

    #def finish_case(kase)
    #end

    def finish_suite(suite)
      total   = suite.count_tests
      failure = suite.count_failures
      error   = suite.count_errors
      pass    = total - failure - error

      bar = '=' * 78
      if COLORIZE
        bar = if pass == total then ::ANSI::Code.green bar
              else ::ANSI::Code.red bar end
      end

      tally = [total, suite.count_assertions]

      io.puts bar
      io.puts "  pass: %d,  fail: %d,  error: %d" % [pass, failure, error]
      io.puts "  total: %d tests with %d assertions in #{Time.new - @time} seconds" % tally
      io.puts bar
    end

  end

end

