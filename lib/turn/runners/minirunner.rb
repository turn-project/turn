require 'stringio'

# Because of some wierdness in MiniTest
#debug, $DEBUG = $DEBUG, false
#require 'minitest/unit'
#$DEBUG = debug

module Turn

  # Turn's MiniTest test runner class.
  #
  class MiniRunner < ::MiniTest::Unit

    #
    def initialize
      @turn_config = Turn.config

      super()

      # a stream we will use to route minitests traditional output
      @out = ::StringIO.new
    end

    # route minitests traditional output to nowhere
    def output
      @out
    end

    #
    def turn_reporter
      @turn_config.reporter
    end

    # Turn calls this method to start the test run.
    def start(args=[])
      # minitest changed #run in 6023c879cf3d5169953e on April 6th, 2011
      if ::MiniTest::Unit.respond_to?(:runner=)
        ::MiniTest::Unit.runner = self
      end
      # FIXME: why isn't @test_count set?
      run(args)
      return @turn_suite
    end

    # Override #_run_suite to setup Turn.
    def _run_suites suites, type
      # Someone want to explain to me why these are fucking here?
      suites = suites - [MiniTest::Spec]
      suites = suites - [Test::Unit::TestCase] if defined?(Test::Unit::TestCase)

      @turn_suite = Turn::TestSuite.new(@turn_config.suite_name)
      @turn_suite.size = suites.size  #::MiniTest::Unit::TestCase.test_suites.size
      @turn_suite.seed = ::MiniTest::Unit.runner.options[:seed]

      turn_reporter.start_suite(@turn_suite)

      if @turn_config.matchcase
        suites = suites.select{ |suite| @turn_config.matchcase =~ suite.name }
      end

      result = suites.map { |suite| _run_suite(suite, type) }

      turn_reporter.finish_suite(@turn_suite)

      return result
    end

    # Override #_run_suite to iterate tests via Turn.
    def _run_suite suite, type
      # suites are cases in minitest
      @turn_case = @turn_suite.new_case(suite.name)

      filter = normalize_filter(@options[:filter]) || @turn_config.pattern || /./

      suite.send("#{type}_methods").grep(/#{filter}/).each do |test|
        @turn_case.new_test(test)
      end

      turn_reporter.start_case(@turn_case)

      header = "#{type}_suite_header"
      puts send(header, suite) if respond_to? header

      assertions = @turn_case.tests.map do |test|
        @turn_test = test
        turn_reporter.start_test(@turn_test)

        inst = suite.new(test.name) #method
        inst._assertions = 0

        result = inst.run self

        if result == "."
          turn_reporter.pass
        end

        turn_reporter.finish_test(@turn_test)

        inst._assertions
      end

      @turn_case.count_assertions = assertions.inject(0) { |sum, n| sum + n }

      turn_reporter.finish_case(@turn_case)

      return assertions.size, assertions.inject(0) { |sum, n| sum + n }
    end

    # Override #puke to update Turn's internals and reporter.
    def puke(klass, meth, err)
      case err
      when MiniTest::Skip
        @turn_test.skip!(err)
        turn_reporter.skip(err)
      when MiniTest::Assertion
        @turn_test.fail!(err)
        turn_reporter.fail(err)
      else
        @turn_test.error!(err)
        turn_reporter.error(err)
      end
      super(klass, meth, err)
    end

    private

    # regex gets turned into a string literal with leading/trailing slashes
    # so remove them
    def normalize_filter(filter)
      filter.sub(/^(\/)/, '').sub(/(\/)$/, '') if filter
    end

  end

end
