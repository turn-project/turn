module Turn
  require 'turn/colorize'
  require 'turn/core_ext'

  # There are two distinct way in which a report may be utilized
  # by a Runner: per-call or per-file. The method #pass, #fail
  # and #error are generic, and will be used in either case.
  # A per-call runner will use all the methods of a Reporter,
  # while a per-file runner will use start_case per file,
  # and will not use the start_test and finish_test methods,
  # since those are beyond it's grainularity.
  #
  class Reporter

    include Colorize

    # Where to send report, defaults to `$stdout`.
    attr :io

    def initialize(io, opts={})
      @io      = io || $stdout
      @trace   = opts[:trace]
      @natural = opts[:natural]
    end

    # These methods are called in the process of running the tests.

    # At the very start, before any testcases are run, this is called.
    def start_suite(test_suite)
    end

    # Invoked before a testcase is run.
    def start_case(test_case)
    end

    # Invoked before a test is run.
    def start_test(test)
    end

    # Invoked when a test passes.
    def pass(message=nil)
    end

    # Invoked when a test raises an assertion.
    def fail(assertion, message=nil)
    end

    # Invoked when a test raises an exception.
    def error(exception, message=nil)
    end

    # Invoked when a test is skipped.
    def skip(exception, message=nil)
    end

    # Invoked after a test has been run.
    def finish_test(test)
    end

    # Invoked after all tests in a testcase have ben run.
    def finish_case(test_case)
    end

    # After all tests are run, this is the last observable action.
    def finish_suite(test_suite)
    end

  private

    # Apply filter_backtrace and limit_backtrace in one go.
    def clean_backtrace(backtrace)
      limit_backtrace(filter_backtrace(backtrace))
    end

    # TODO: Is the text/unit line needed any more now that Dir.pwd is excluded
    #       from filtering?

    $RUBY_IGNORE_CALLERS ||= []
    $RUBY_IGNORE_CALLERS.concat([
      /\/lib\/turn.*\.rb/,
      /\/bin\/turn/,
      /\/lib\/minitest.*\.rb/,
      /\/test\/unit(?!(\/.*\_test.rb)|.*\/test_.*).*\.rb.*/
    ])

    # Filter backtrace of unimportant entries, and applies count limit if set in
    # configuration. Setting $DEBUG to true will deactivate filter, or if the filter
    # happens to remove all backtrace entries it will revert to the full backtrace,
    # as that probably means there was an issue with the test harness itself.
    def filter_backtrace(backtrace)
      return [] unless backtrace
      bt, pwd = backtrace.dup, Dir.pwd
      unless $DEBUG
        bt = bt.reject do |line|
          $RUBY_IGNORE_CALLERS.any?{|re| re =~ line} unless line.start_with?(pwd)
        end
      end
      bt = backtrace if bt.empty?  # if empty just dump the whole thing
      bt.map{ |line| line.sub(pwd+'/', '') }
    end

    # Limit backtrace to number of lines if `trace` configuration option is set.
    def limit_backtrace(backtrace)
      return [] unless backtrace
      @trace ? backtrace[0, @trace.to_i] : backtrace
    end

    #
    def naturalized_name(test)
      if @natural
        test.name.gsub("test_", "").gsub(/_/, " ")
      else
        test.name
      end
    end

    #
    def ticktock
      t = Time.now - @time
      h, t = t.divmod(60)
      m, t = t.divmod(60)
      s = t.truncate
      f = ((t - s) * 1000).to_i

      "%01d:%02d:%02d.%03d" % [h,m,s,f]
    end
  end

end
