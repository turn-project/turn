require 'turn/reporter'
require 'ansi/progressbar'

module Turn

  #
  class ProgressReporter < Reporter

    def initialize(io, opts={})
      super(io, opts)
      @fails  = Hash.new{|h,k|h[k]=[]}
      @errors = Hash.new{|h,k|h[k]=[]}
    end

    def start_suite(suite)
      @pbar = ::ANSI::Progressbar.new('Testing', suite.size)
      @pbar.inc
    end

    def start_case(testcase)
      @_current_case = testcase
    end

    #def start_test(test)
    #end

    #def pass(message=nil)
    #  #@pbar.inc
    #end

    #def fail(message=nil)
    def fail(assertion, message=nil)
      #@pbar.inc
      @fails[@_current_case] << assertion
    end

    def error(exception, message=nil)
      #@pbar.inc
      @errors[@_current_case] << exception
    end

    def finish_case(kase)
      @pbar.inc
    end

    def finish_suite(suite)
      @pbar.finish
      post_report(suite)
    end

    #
    def post_report(suite)
      tally = test_tally(suite)

      width = suite.collect{ |tr| tr.name.size }.max

      headers = [ 'TESTCASE  ', '  TESTS   ', 'ASSERTIONS', ' FAILURES ', '  ERRORS   ' ]
      io.puts "\n\n%-#{width}s       %10s %10s %10s %10s\n" % headers

      io.puts ("-" * (width + 50))

      files = nil
      suite.each do |testrun|
        if testrun.files != [testrun.name] && testrun.files != files
          label = testrun.files.join(' ')
          label = Colorize.magenta(label)
          io.puts(label + "\n")
          files = testrun.files
        end
        io.puts paint_line(testrun, width)
      end

      #puts("\n%i tests, %i assertions, %i failures, %i errors\n\n" % tally)

      tally_line = ("-" * (width + 50))
      tally_line << "\n%-#{width}s  " % "TOTAL"
      tally_line << "%10s %10s %10s %10s" % tally

      io.puts(tally_line + "\n\n\n")

      io.puts "-- Failures --\n\n" unless @fails.empty?

      @fails.each do |tc, cc|
        cc.each do |e|
          message = e.message.tabto(0).strip
          message = Colorize.red(message)
          message += "\n" + clean_backtrace(e.backtrace).join("\n")
          io.puts(message+"\n\n")
        end
        io.puts
      end

      io.puts "-- Errors --\n\n" unless @errors.empty?

      @errors.each do |tc, cc|
        cc.each do |e|
          message = e.message.tabto(0).strip
          message = Colorize.red(message)
          message += "\n" + clean_backtrace(e.backtrace).join("\n")
          io.puts(message+"\n\n")
        end
        io.puts
      end

      #fails = suite.select do |testrun|
      #  testrun.fail? || testrun.error?
      #end

      ##if tally[2] != 0 or tally[3] != 0
      #  unless fails.empty? # or verbose?
      #    io.puts "\n\n-- Failures and Errors --\n\n"
      #    fails.uniq.each do |testrun|
      #      message = testrun.message.tabto(0).strip
      #      message = Colorize.red(message)
      #      # backtrace ?
      #      #message += clean_backtrace(testrun.exception.backtrace).join("\n")
      #      io.puts(message+"\n\n")
      #    end
      #    io.puts
      #  end
      ##end
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

