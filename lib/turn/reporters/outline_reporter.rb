require 'turn/reporter'
require 'stringio'

module Turn

  # = Outline Reporter (Turn's Original)
  #
  #--
  # TODO: Should we fit reporter output to width of console?
  # TODO: Running percentages?
  #++
  class OutlineReporter < Reporter

    #
    def start_suite(suite)
      @suite = suite
      @time  = Time.now
      @stdout = StringIO.new
      @stderr = StringIO.new
      #files = suite.collect{ |s| s.file }.join(' ')
      io.puts "LOADED SUITE #{suite.name}"
      #io.puts "Started"
    end

    #
    def start_case(kase)
      io.puts(Colorize.bold("#{kase.name}"))
    end

    #
    def start_test(test)
      #if @file != test.file
      #  @file = test.file
      #  io.puts(test.file)
      #end
      io.print "    %-69s" % test.name

      @stdout.rewind
      @stderr.rewind

      $stdout = @stdout
      $stderr = @stderr unless $DEBUG
    end

    #
    def pass(message=nil)
      io.puts " #{PASS}"
      if message
        message = Colorize.magenta(message)
        message = message.to_s.tabto(8)
        io.puts(message)
      end
    end

    #
    def fail(assertion)
      message   = assertion.message.to_s
      backtrace = filter_backtrace(assertion.backtrace)

      io.puts(" #{FAIL}")
      io.puts Colorize.bold(message).tabto(8)
      unless backtrace.empty?
        _backtrace = filter_backtrace(assertion.backtrace)
        label = "Assertion at "
        tabsize = 8
        backtrace = label + _backtrace.shift
        io.puts(backtrace.tabto(tabsize))
        if @trace
          io.puts _backtrace.map{|l| l.tabto(label.length + tabsize) }.join("\n")
        end
      end
      show_captured_output
    end

    #
    def error(exception)
      message   = exception.message
      backtrace = "Exception `#{exception.class}' at " + filter_backtrace(exception.backtrace).join("\n")
      message = Colorize.bold(message)
      io.puts("#{ERROR}")
      io.puts(message.tabto(8))
      io.puts "STDERR:".tabto(8)
      io.puts(backtrace.tabto(8))
      show_captured_output
    end

    #
    def finish_test(test)
      $stdout = STDOUT
      $stderr = STDERR
    end

    #
    def show_captured_output
      show_captured_stdout
      #show_captured_stderr
    end

    #
    def show_captured_stdout
      @stdout.rewind
      return if @stdout.eof?
      STDOUT.puts(<<-output.tabto(8))
\nSTDOUT:
#{@stdout.read}
      output
    end

# No longer used b/c of error messages are fairly extraneous.
=begin
    def show_captured_stderr
      @stderr.rewind
      return if @stderr.eof?
      STDOUT.puts(<<-output.tabto(8))
\nSTDERR:
#{@stderr.read}
      output
    end
=end

    #
    #def finish_case(kase)
    #end

    #
    def finish_suite(suite)
      total   = suite.count_tests
      failure = suite.count_failures
      error   = suite.count_errors
      pass    = total - failure - error

      bar = '=' * 78
      if COLORIZE
        bar = if pass == total then Colorize.green(bar)
              else Colorize.red(bar) end
      end

      tally = [total, suite.count_assertions]

      io.puts bar
      io.puts "  pass: %d,  fail: %d,  error: %d" % [pass, failure, error]
      io.puts "  total: %d tests with %d assertions in #{Time.new - @time} seconds" % tally
      io.puts bar
    end

  end

end

