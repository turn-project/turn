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
    TAB_SIZE = 8

    #
    def start_suite(suite)
      @suite  = suite
      @time   = Time.now
      @stdout = StringIO.new
      @stderr = StringIO.new
      #files  = suite.collect{ |s| s.file }.join(' ')
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

      name = if @natural
               " #{test.name.gsub("test_", "").gsub(/_/, " ")}" 
             else
               " #{test.name}"
             end

      io.print "    %-69s" % name

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
        message = message.to_s.tabto(TAB_SIZE)
        io.puts(message)
      end
    end

    #
    def fail(assertion)
      io.puts(" #{FAIL}")

      message = []
      message << Colorize.bold(assertion.message.to_s)
      message << "Assertion at:"
      message << clean_backtrace(assertion.backtrace).join("\n")
      message = message.join("\n")

      io.puts(message.tabto(TAB_SIZE))

      #unless backtrace.empty?
      #  io.puts "Assertion at".tabto(TAB_SIZE)
      #  io.puts backtrace.map{|l| l.tabto(TAB_SIZE)}.join("\n")
      #end

      #io.puts "STDERR:".tabto(TAB_SIZE)
      show_captured_output
    end

    #
    def error(exception)
      io.puts(" #{ERROR}")

      message = []
      message << Colorize.bold(exception.message)
      message << "Exception `#{exception.class}' at:"
      message << clean_backtrace(exception.backtrace).join("\n")
      message = message.join("\n")

      io.puts(message.tabto(TAB_SIZE))

      #io.puts "STDERR:".tabto(TAB_SIZE)
      show_captured_output
    end

    #
    def skip(exception)
      message = exception.message      

      io.puts(" #{SKIP}")
      io.puts(message.tabto(8))

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

    # TODO: pending (skip) counts
    def finish_suite(suite)
      total   = suite.count_tests
      failure = suite.count_failures
      error   = suite.count_errors
      pass    = total - failure - error

      bar = '=' * 78
      if colorize?
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

