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

    def fail(message=nil)
      io.print Colorize.fail('F'); io.flush
    end

    def error(message=nil)
      io.print Colorize.error('E'); io.flush
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
          message = testunit.fail? ? ' ' + FAIL : ERROR
          message = message + ' ' + testunit.message.tabto(0)
          message << "\n" + (filter_backtrace(testunit.backtrace).first || '')
          report << "\n" << message << "\n"
        end
        report << "\n"
      end

      io.puts report

      count = test_tally(suite)

      tally = "%s tests, %s assertions, %s failures, %s errors" % count
 
      if count[-1] > 0 or count[-2] > 0
        tally = Colorize.red(tally)
      else
        tally = Colorize.green(tally)
      end

      io.puts tally
    end

  private

    def test_tally(suite)
      counts = suite.collect{ |tr| tr.counts }
      tally  = [0,0,0,0]
      counts.each do |count|
        4.times{ |i| tally[i] += count[i] }
      end
      return tally
    end

  end

end

