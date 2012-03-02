require 'turn/reporter'

module Turn

  # = Traditional Dot Reporter
  #
  class DotReporter < Reporter

    def start_suite(suite)
      @time = Time.now
      io.puts "Loaded suite #{suite.name}"
      io.puts "Started"
    end

    def start_case(kase)
    end

    def start_test(test)
    end

    def pass(message=nil)
      io.print Colorize.pass('.'); io.flush
    end

    def fail(assertion, message=nil)
      io.print Colorize.fail('F'); io.flush
    end

    def error(exception, message=nil)
      io.print Colorize.error('E'); io.flush
    end

    def skip(exception, message=nil)
      io.print Colorize.skip('S'); io.flush
    end

    def finish_test(test)
    end

    def finish_case(kase)
    end

    def finish_suite(suite)
      io.puts("\nFinished in %.5f seconds." % [Time.now - @time])

      report = ''

      list = []
      suite.each do |testcase|
        testcase.each do |testunit|
          if testunit.fail? || testunit.error?
            list << testunit
          end
        end
      end

      unless list.empty? # or verbose?
        #report << "\n\n-- Failures and Errors --\n\n"
        list.uniq.each do |testunit|
          message = []
          message << (testunit.fail? ? FAIL : ERROR)
          message << testunit.message.tabto(2)
          message << clean_backtrace(testunit.backtrace).join("\n").tabto(2)
          report << "\n" << message.join("\n") << "\n"
        end
        report << "\n"
      end

      io.puts report

      # @TODO: Add something like suite.count(:tests, :passes) or
      #        suite.count(tests: "%d tests", passes: "%d passes")
      #        to cleanup, which will return something handy
      #        (suite.count(:test, :passes).test proxy maybe?)
      total      = "%d tests" % suite.count_tests
      passes     = "%d passed" % suite.count_passes
      assertions = "%d assertions" % suite.count_assertions
      failures   = "%s failures" % suite.count_failures
      errors     = "%s errors" % suite.count_errors
      skips      = "%s skips" % suite.count_skips

      tally = [total, passes, assertions, failures, errors, skips].join(", ")

      io.puts suite.passed? ? Colorize.green(tally) : Colorize.red(tally)
    end

  end

end