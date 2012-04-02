require 'turn/reporter'
require 'stringio'

module Turn

  # Outline Reporter is Turn's Original.
  #
  #--
  # TODO: Should we fit reporter output to width of console?
  #       y8: Yes. we should, but it's a kinda tricky, if you want to make it
  #           cross-platform. (See https://github.com/cldwalker/hirb/blob/master/lib/hirb/util.rb#L61)
  # TODO: Running percentages?
  # TODO: Cleanup me!
  #++
  class OutlineReporter < Reporter

    #
    TAB_SIZE = 8

    #
    def start_suite(suite)
      @suite  = suite
      @time   = Time.now
      # @FIXME (y8): Why we need to capture stdout and stderr?
      @stdout = StringIO.new
      @stderr = StringIO.new
      #files  = suite.collect{ |s| s.file }.join(' ')
      puts '=' * 78
      if suite.seed
        io.puts "SUITE #{suite.name} (SEED #{suite.seed})"
      else
        io.puts "SUITE #{suite.name}"
      end
      puts '=' * 78
    end

    #
    def start_case(kase)
      io.puts(Colorize.bold("#{kase.name}")) if kase.size > 0
    end

    #
    def start_test(test)
      #if @file != test.file
      #  @file = test.file
      #  io.puts(test.file)
      #end

      # @FIXME: Should we move naturalized_name to test itself?
      name = naturalized_name(test)

      io.print "    %-57s" % name

      @stdout.rewind
      @stderr.rewind

      $stdout = @stdout
      $stderr = @stderr unless $DEBUG
    end

    #
    def pass(message=nil)
      io.puts " %s %s" % [ticktock, PASS]

      if message
        message = Colorize.magenta(message)
        message = message.to_s.tabto(TAB_SIZE)
        io.puts(message)
      end
    end

    #
    def fail(assertion)
      io.puts " %s %s" % [ticktock, FAIL]

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
      io.puts " %s %s" % [ticktock, ERROR]

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
      io.puts " %s %s" % [ticktock, SKIP]

      message = exception.message

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
      total      = suite.count_tests
      passes     = suite.count_passes
      assertions = suite.count_assertions
      failures   = suite.count_failures
      errors     = suite.count_errors
      skips      = suite.count_skips

      bar = '=' * 78
      bar = passes == total ? Colorize.green(bar) : Colorize.red(bar)

      # @FIXME: Should we add suite.runtime, instead if this lame time calculations?
      tally = [total, assertions, (Time.new - @time)]

      io.puts bar
      io.puts "  pass: %d,  fail: %d,  error: %d, skip: %d" % [passes, failures, errors, skips]
      io.puts "  total: %d tests with %d assertions in %f seconds" % tally
      io.puts bar
    end

  end

end
