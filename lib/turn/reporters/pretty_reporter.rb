require 'turn/reporter'

module Turn

  # = Pretty Reporter (by Paydro)
  #
  class PrettyReporter < Reporter
    #
    PADDING_SIZE = 4

    #
    TAB_SIZE = 10

    #
    def start_suite(suite)
      #old_sync, @@out.sync = @@out.sync, true if io.respond_to? :sync=
      @suite  = suite
      @time   = Time.now
      #@stdout = StringIO.new
      #@stderr = StringIO.new
      #files = suite.collect{ |s| s.file }.join(' ')
      io.puts "Loaded suite #{suite.name}"
      #io.puts "Loaded suite #{$0.sub(/\.rb$/, '')}\nStarted"
      io.puts "Started (#{suite.seed})"
    end

    #
    def start_case(kase)
      #if kase.size > 0  # TODO: Don't have size yet?
        io.print "\n#{kase.name}:\n"
      #end
    end

    #
    def start_test(test)
      @test_time = Time.now
      @test = test
      #if @file != test.file
      #  @file = test.file
      #  io.puts(test.file)
      #end
      #io.print "    %-69s" % test.name
      #$stdout = @stdout
      #$stderr = @stderr
      #$stdout.rewind
      #$stderr.rewind
    end

    #
    def pass(message=nil)
      io.print pad_with_size("#{PASS}")
      io.print " #{@test}"
      io.print " (%.2fs) " % (Time.now - @test_time)
      if message
        message = Colorize.magenta(message)
        message = message.to_s.tabto(10)
        io.puts(message)
      end
    end

    #
    def fail(assertion, message=nil)
      io.print pad_with_size("#{FAIL}")
      io.print " #{@test}"
      io.print " (%.2fs) " % (Time.now - @test_time)

      #message = assertion.location[0] + "\n" + assertion.message #.gsub("\n","\n")
      #trace   = MiniTest::filter_backtrace(report[:exception].backtrace).first

      message ||= assertion.message

      _trace = if assertion.respond_to?(:backtrace)
                 filter_backtrace(assertion.backtrace)
               else
                 filter_backtrace(assertion.location).first
               end

      io.puts
      #io.puts pad(message, tabsize)
      io.puts message.tabto(TAB_SIZE)

      cnt = @trace ? @trace.to_i : _trace.size
      io.puts _trace[0, cnt].map{|l| l.tabto(TAB_SIZE) }.join("\n")

      #show_captured_output
    end

    #
    def error(exception, message=nil)
      io.print pad_with_size("#{ERROR}")
      io.print " #{@test}"
      io.print " (%.2fs) " % (Time.now - @test_time)

      #message = exception.to_s.split("\n")[2..-1].join("\n")

      message ||= exception.message

      _trace = if exception.respond_to?(:backtrace)
                 clean_backtrace(exception.backtrace)
               else
                 clean_backtrace(exception.location)
               end

      io.puts
      io.puts message.tabto(TAB_SIZE)
      io.puts _trace.map{|l| l.tabto(TAB_SIZE) }.join("\n")
    end

    #
    def skip(exception, message=nil)
      io.print pad_with_size("#{SKIP}")
      io.print " #{@test}"
      io.print " (%.2fs) " % (Time.now - @test_time)

      message ||= exception.message

      _trace = if exception.respond_to?(:backtrace)
                 clean_backtrace(exception.backtrace)
               else
                 clean_backtrace(exception.location)
               end

      io.puts
      io.puts message.tabto(TAB_SIZE)
      io.puts _trace.map{|l| l.tabto(TAB_SIZE) }.join("\n")
    end

    #
    def finish_test(test)
      io.puts
      #@test_count += 1
      #@assertion_count += inst._assertions
      #$stdout = STDOUT
      #$stderr = STDERR
    end

=begin
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
=end

    def finish_case(kase)
      if kase.size == 0
        io.puts pad("(No Tests)")
      end
    end

    #
    def finish_suite(suite)
      #@@out.sync = old_sync if @@out.respond_to? :sync=

      total   = suite.count_tests
      failure = suite.count_failures
      error   = suite.count_errors
      #pass    = total - failure - error

      io.puts
      io.puts "Finished in #{'%.6f' % (Time.now - @time)} seconds."
      io.puts

      io.print "%d tests, " % total
      io.print "%d assertions, " % suite.count_assertions
      io.print Colorize.fail( "%d failures" % failure) + ', '
      io.print Colorize.error("%d errors" % error) #+ ', '
      #io.puts  Colorize.cyan( "%d skips" % skips ) #TODO
      io.puts
    end

  private

    #
    def pad(str, size=PADDING_SIZE)
      " " * size + str
    end

    #
    def pad_with_size(str)
      " " * (18 - str.size) + str
    end

  end

end

