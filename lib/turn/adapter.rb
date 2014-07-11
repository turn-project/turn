# Minitest adaptor for Turn.

# Have to make sure the latest version of minitest is used.
#begin; gem 'minitest'; rescue; end

#require 'minitest/unit'
#require 'minitap/ignore_callers'
require 'stringio'

# Becuase of some wierdness in MiniTest
#debug, $DEBUG = $DEBUG, false
#require 'minitest/unit'
#$DEBUG = debug

module Minitest

  ##
  # Base class for Turn::Reporter.
  #
  class TurnAdapter < StatisticsReporter #Reporter

    # Backtrace patterns to be omitted.
    #IGNORE_CALLERS = $RUBY_IGNORE_CALLERS

    # Test results.
    #attr_reader :test_results

    attr_reader :test_cases
    attr_reader :test_count

    attr_accessor :suite_start_time
    attr_accessor :case_start_time
    attr_accessor :test_start_time

    # Initialize new Minitap Minitest reporter.
    def initialize(options={})
      io = options.delete(:io) || $stdout

      super(io, options)

      # since tapout uses a unix pipe, we don't want any buffering
      io.sync = true

      #@_stdout = StringIO.new
      #@_stderr = StringIO.new

      #@test_results = {}
      #self.assertion_count = 0

      @_source_cache = {}
    end

    #
    # Minitest's initial hook ran just before testing begins.
    #
    def start
      super

      @turn_config = Turn.config
      @turn_suite  = Turn::TestSuite.new(@turn_config.suite_name)

      @test_cases = {}
      Runnable.runnables.each do |c|
        @test_cases[c] = @turn_suite.new_case(c.name) #Turn::TestCase.new(c)
      end

      @turn_suite.seed  = options[:seed]
      @turn_suite.cases = @test_cases.values
      @turn_suite.size  = @test_cases.size  #::MiniTest::Unit::TestCase.test_suites.size

      capture_io

      #@_stdout, @_stderr = capture_io do
      #  super_result = super(suite, type)
      #end

      start_suite(@turn_suite)
    end

    #
    # Process a test result.
    #
    def record(minitest_result)
      super(minitest_result)

      result = TestResult.new(minitest_result)

      #if exception #&& ENV['minitap_debug']
      #  STDERR.puts exception
      #  STDERR.puts exception.backtrace.join("\n")
      #end

      #@test_results[suite] ||= {}
      #@test_results[suite][test.to_sym] = record

      case_change = false

      kase = @test_cases[result.test_case]

      # in the old runner version we created all of these before running any tests
      test = kase.new_test(result.name)

      if @previous_case != result.test_case
        case_change = true  
        start_case(kase)
      end

      start_test(test) #(result)

      case result.type
      when :skip
        test.skip!(result.exception)
        skip(result.exception)
      when :fail
        test.fail!(result.exception)
        fail(result.exception)
      when :err
        test.error!(result.exception)
        error(result.exception)
      when :pass
        pass() #result
      end

      finish_test(test) #result)

      if case_change
        finish_case(kase)
      end

      @previous_case = result.test_case
    end

    #
    # Minitest's finalization hook.
    #
    def report
      super

      uncapture_io

      finish_suite(@turn_suite)
    end

  private

    #
    def count_tests!(test_cases)
      filter = options[:filter] || '/./'
      filter = Regexp.new $1 if filter =~ /\/(.*)\//

      @test_count = test_cases.inject(0) do |acc, test_case|
        acc + test_case.runnable_methods.grep(filter).length
      end
    end

    # Stub out the three IO methods used by the built-in reporter.
    def p(*args)
      args.each{ |a| io.print(a.inspect); puts }
    end

    def puts(*args)
      io.puts(*args)
    end

    def print(*args)
      io.print(*args)
    end

    #
    def capture_io
      @_stdout, @_stderr = $stdout, $stderr
      $stdout, $stderr = StringIO.new, StringIO.new
    end

    #
    def uncapture_io
      $stdout, $stderr = @_stdout, @_stderr
    end

  end

  ##
  # TestResult delegtes to Minitest's own test result object.
  #
  class TestResult
    # Create new TestResult instance.
    #
    # result - MiniTest's test result object.
    #
    def initialize(result)
      @result = result
    end

    def test_case
      @result.class
    end
    alias :testcase :test_case

    # Name of the test.
    def name
      @result.name
    end
    alias :test :name

    #
    def label
      if spec?
        name.sub(/^test_\d+_/, '').gsub('_', ' ')
      else
        name
      end
    end

    # Is this a Minitest::Spec?
    #
    # Returns [Boolean].
    def spec?
      @is_spec ||= (
        Minitest.const_defined?(:Spec) && @result.class < Minitest::Spec
        #@result.class.methods.include?(:it) || @result.class.methods.include?('it')
      )
    end

    # Number of assertions made by test.
    #
    # Returns [Integer].
    def assertions
      @result.assertions
    end

    #
    def time
      @result.time
    end

    #
    def exception
      @result.failure
    end

    # Result type.
    def type
      case exception
      when UnexpectedError
        :err
      when Skip
        :skip
      when Assertion
        :fail
      when nil 
        :pass
      else 
        :err
      end
    end
  end

end
