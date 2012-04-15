require 'turn/reporter'

module Turn
  # = Pretty Reporter (by Paydro)
  #
  # Example output:
  #    TestCaseName:
  #         PASS test: Succesful test case.  (0:00:02:059)
  #        ERROR test: Bogus test case.  (0:00:02:059)
  #         FAIL test: Failed test case.  (0:00:02:059)
  #
  class PrettyReporter < Reporter
    # Second column left padding in chars.
    TAB_SIZE = 10

    # Character to put in front of backtrace.
    TRACE_MARK = '@ '

    # TODO: solo and cross runners do not have name or seed, need to fix.

    # At the very start, before any testcases are run, this is called.
    def start_suite(suite)
      @suite  = suite
      @time   = Time.now

      io.puts Colorize.bold("Loaded Suite #{suite.name}")
      io.puts
      if suite.seed
        io.puts "Started at #{Time.now} w/ seed #{suite.seed}."
      else
        io.puts "Started at #{Time.now}."
      end
      io.puts
    end

    # Invoked before a testcase is run.
    def start_case(kase)
      # Print case name if there any tests in suite
      # TODO: Add option which will show all test cases, even without tests?
      io.puts kase.name if kase.size > 0
    end

    # Invoked before a test is run.
    def start_test(test)
      @test_time = Time.now
      @test = test
    end

    # Invoked when a test passes.
    def pass(message=nil)
      banner PASS

      if message
        message = Colorize.magenta(message)
        message = message.to_s.tabto(TAB_SIZE)

        io.puts(message)
      end
    end

    # Invoked when a test raises an assertion.
    def fail(assertion, message=nil)
      banner FAIL

      prettify(assertion, message)
    end

    # Invoked when a test raises an exception.
    def error(exception, message=nil)
      banner ERROR

      prettify(exception, message)
    end

    # Invoked when a test is skipped.
    def skip(exception, message=nil)
      banner SKIP

      prettify(exception, message)
    end

    # Invoked after all tests in a testcase have ben run.
    def finish_case(kase)
      # Print newline is there any tests in suite
      io.puts if kase.size > 0
    end

    # After all tests are run, this is the last observable action.
    def finish_suite(suite)
      total      = colorize_count("%d tests", suite.count_tests, :bold)
      passes     = colorize_count("%d passed", suite.count_passes, :pass)
      assertions = colorize_count("%d assertions", suite.count_assertions, nil)
      failures   = colorize_count("%d failures", suite.count_failures, :fail)
      errors     = colorize_count("%d errors", suite.count_errors, :error)
      skips      = colorize_count("%d skips", suite.count_skips, :skip)

      io.puts "Finished in %.6f seconds." % (Time.now - @time)
      io.puts

      io.puts [ total, passes, failures, errors, skips, assertions ].join(", ")

      # Please keep this newline, since it will be useful when after test case
      # there will be other lines. For example "rake aborted!" or kind of.
      io.puts
    end

  private
    # Creates an optionally-colorized string describing the number of occurances an event occurred.
    #
    # @param [String] str A printf-style string that expects an integer argument (i.e. the count)
    # @param [Integer] count The number of occurances of the event being described.
    # @param [nil, Symbol] colorize_method The method on Colorize to call in order to apply color to the result, or nil
    #   to not apply any coloring at all.
    def colorize_count(str, count, colorize_method)
      str= str % [count]
      str= Colorize.send(colorize_method, str) if colorize_method and count != 0
      str
    end

    # TODO: Could also provide % done with time info. But it's already taking up
    #       a lot of screen realestate. Maybe use --verbose flag to offer two forms.

    # Outputs test case header for given event (error, fail & etc)
    #
    # Example:
    #    PASS test: Test decription.  (0.15s 0:00:02:059)
    def banner(event)
      name = naturalized_name(@test)
      delta = Time.now - @test_time  # test runtime
      if @verbose
        out = "%18s (%0.5fs) (%s) %s" % [event, delta, ticktock, name]
      else
        out = "%18s (%s) %s" % [event, ticktock, name]
      end
      if @mark > 0 && delta > @mark
        out[1] = Colorize.mark('*')
      end
      io.puts out
    end

    # Cleanups and prints test payload
    #
    # Example:
    #         fail is not 1
    #       @ test/test_runners.rb:46:in `test_autorun_with_trace'
    #         bin/turn:4:in `<main>'
    def prettify(raised, message=nil)
      # Get message from raised, if not given
      message ||= raised.message

      backtrace = raised.respond_to?(:backtrace) ? raised.backtrace : raised.location

      # Filter and clean backtrace
      backtrace = clean_backtrace(backtrace)

      # Add trace mark to first line.
      backtrace.first.insert(0, TRACE_MARK)

      io.puts Colorize.bold(message.tabto(TAB_SIZE))
      io.puts backtrace.shift.tabto(TAB_SIZE - TRACE_MARK.length)
      io.puts backtrace.join("\n").tabto(TAB_SIZE)
      io.puts
    end
  end
end
