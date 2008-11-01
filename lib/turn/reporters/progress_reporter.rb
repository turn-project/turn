require 'turn/reporter'
require 'facets/progressbar'
require 'facets/string/tab'

module Turn

  #
  class ProgressReporter < Reporter

    def start_suite(suite)
      @pbar = ::ProgressBar.new('Testing', suite.size)
      @pbar.inc
    end

    #def start_case(kase)
    #end

    #def start_test(test)
    #end

    def pass(message=nil)
      @pbar.inc
    end

    def fail(message=nil)
      @pbar.inc
    end

    def error(message=nil)
      @pbar.inc
    end

    #def finish_case(kase)
    #end

    def finish_suite(suite)
      @pbar.finish
      post_report(suite)
    end

    #
    def post_report(suite)
      report = ''

      tally = test_tally(suite)

      width = suite.collect{ |tr| tr.name.size }.max

      headers = [ 'TESTCASE  ', '  TESTS   ', 'ASSERTIONS', ' FAILURES ', '  ERRORS   ' ]
      report << "\n%-#{width}s       %10s %10s %10s %10s\n" % headers

      files = nil

      suite.each do |testrun|
        if testrun.files != [testrun.name] && testrun.files != files
          report << testrun.files.join(' ') + "\n"
          files = testrun.files
        end
        report << paint_line(testrun, width)
        report << "\n"
      end

      #puts("\n%i tests, %i assertions, %i failures, %i errors\n\n" % tally)

      tally_line = "-----\n"
      tally_line << "%-#{width}s  " % "TOTAL"
      tally_line << "%10s %10s %10s %10s" % tally

      report << tally_line
      report << "\n\n"

      fails = suite.select do |testrun|
        testrun.fail? || testrun.error?
      end

      #if tally[2] != 0 or tally[3] != 0
        unless fails.empty? # or verbose?
          report << "-- Failures and Errors --\n\n"
          fails.uniq.each do |testrun|
            message = testrun.message.tabto(0)
            message = ::ANSICode.magenta(message) if COLORIZE
            report << message << "\n"
          end
          report << "\n"
        end
      #end

      io.puts report
    end

  private

    def paint_line(testrun, width)
      line = ''
      line << "%-#{width}s  " % [testrun.name]
      line << "%10s %10s %10s %10s" % testrun.counts
      line << " " * 8
      if testrun.fail?
        line << "[#{FAIL}]"
      elsif testrun.error?
        line << "[#{FAIL}]"
      else
        line << "[#{PASS}]"
      end
      line
    end

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

