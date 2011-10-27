module Turn
  require 'turn/colorize'
  require 'turn/core_ext'

  # = Reporter
  #
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

    attr :io

    def initialize(io, opts={})
      @io      = io || $stdout
      @trace   = opts[:trace]
      @natural = opts[:natural]
    end

    # These methods are called in the process of running the tests.

    def start_suite(test_suite)
    end

    def start_case(test_case)
    end

    def start_test(test)
    end

    def pass(message=nil)
    end

    def fail(assertion, message=nil)
    end

    def error(exception, message=nil)
    end

    def finish_test(test)
    end

    def finish_case(test_case)
    end

    def finish_suite(test_suite)
    end

  private

    # Apply filter_backtrace and limit_backtrace in one go.
    def clean_backtrace(backtrace)
      limit_backtrace(filter_backtrace(backtrace))
    end

    # TODO: backtrace filter probably could use some refinement.
    def filter_backtrace(backtrace)
      return [] unless backtrace
      bt = backtrace.dup
      bt.reject!{ |line| line.rindex('minitest') }
      bt.reject!{ |line| line.rindex('test/unit') }
      bt.reject!{ |line| line.rindex('lib/turn') }
      bt.reject!{ |line| line.rindex('bin/turn') }
      bt = backtrace if bt.empty?  # if empty just dump the whole thing
      bt.map{ |line| line.sub(Dir.pwd+'/', '') }
    end

    #
    def limit_backtrace(backtrace)
      return [] unless backtrace
      @trace ? backtrace[0, @trace.to_i] : backtrace
    end

  end

end

