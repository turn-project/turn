require 'stringio'

# Becuase of some wierdness in MiniTest
debug, $DEBUG = $DEBUG, false
require 'minitest/unit'
$DEBUG = debug

Test = MiniTest

module Turn

  # = MiniTest TestRunner
  #
  class MiniRunner < ::MiniTest::Unit

    # Override initialize to take controller argument.
    def initialize(controller)
      @turn_controller = controller

      controller.loadpath.each{ |path| $: << path } unless controller.live?
      controller.requires.each{ |path| require(path) }

      [controller.files].flatten.each{ |path| require(path) }

      files = [controller.files].flatten
      files.each{ |path| require(path) }   

      # TODO: Better name ?
      @turn_suite_name = files.map{ |path| File.dirname(path).sub(Dir.pwd+'/','') }.uniq.join(',')

      #sub_suites = []
      #ObjectSpace.each_object(Class) do |klass|
      #  if(Test::Unit::TestCase > klass)
      #    sub_suites << klass.suite
      #  end
      #end
      #suite = Test::Unit::TestSuite.new('')  # FIXME: Name?
      #sub_suites.sort_by{|s|s.name}.each{|s| suite << s}

      #suite.tests.each do |c|
      #  pattern = controller.pattern
      #  c.tests.reject! { |t| pattern !~ t.method_name }
      #end

      @turn_logger = controller.reporter

      super()

      # route minitests traditional output to nowhere
      # (instead of overriding #puts and #print)
      @@out = ::StringIO.new
    end

    # Turn calls this method to start the test run.
    def start(args=[])
      run(args)
      return @turn_suite
    end

    # Override #_run_suite to setup Turn.
    def _run_suites suites, type
      @turn_suite = Turn::TestSuite.new(@turn_suite_name)
      @turn_suite.size = ::MiniTest::Unit::TestCase.test_suites.size

      @turn_logger.start_suite(@turn_suite)

      if @turn_controller.matchcase
        suites = suites.select{ |suite| @turn_controller.matchcase =~ suite.name }
      end

      result = suites.map { |suite| _run_suite(suite, type) }

      @turn_logger.finish_suite(@turn_suite)

      return result
    end

    # Override #_run_suite to iterate tests via Turn.
    def _run_suite suite, type
      # suites are cases in minitest
      @turn_case = @turn_suite.new_case(suite.name)

      filter = @turn_controller.pattern || /./

      suite.send("#{type}_methods").grep(filter).each do |test|
        @turn_case.new_test(test)
      end

      @turn_logger.start_case(@turn_case)

      header = "#{type}_suite_header"
      puts send(header, suite) if respond_to? header

      assertions = @turn_case.tests.map do |test|
        @turn_test = test
        @turn_logger.start_test(@turn_test)

        inst = suite.new(test.name) #method
        inst._assertions = 0

        result = inst.run self

        if result == "."
          @turn_logger.pass
        end

        @turn_logger.finish_test(@turn_test)

        inst._assertions
      end

      @turn_case.count_assertions = assertions.inject(0) { |sum, n| sum + n }

      @turn_logger.finish_case(@turn_case)

      return assertions.size, assertions.inject(0) { |sum, n| sum + n }
    end

    # Override #puke to update Turn's internals and reporter.
    def puke(klass, meth, err)
      case err
      when MiniTest::Skip
        @turn_test.skip!
        @turn_logger.skip #(e)
      when MiniTest::Assertion
        @turn_test.fail!(err)
        @turn_logger.fail(err)
      else
        @turn_test.error!(err)
        @turn_logger.error(err)
      end
      super(klass, meth, err)
    end

    # To maintain compatibility with old versions of MiniTest.
    if ::MiniTest::Unit::VERSION < '2.0'

      #attr_accessor :options

      #
      def run(args=[])
        suites = ::MiniTest::Unit::TestCase.test_suites
        return if suites.empty?

        @test_count, @assertion_count = 0, 0
        sync = @@out.respond_to? :"sync=" # stupid emacs
        old_sync, @@out.sync = @@out.sync, true if sync

        results = _run_suites suites, :test #type

        @test_count      = results.inject(0) { |sum, (tc, _)| sum + tc }
        @assertion_count = results.inject(0) { |sum, (_, ac)| sum + ac }

        @@out.sync = old_sync if sync

        return failures + errors if @test_count > 0 # or return nil...
      rescue Interrupt
        abort 'Interrupted'
      end

    end

  end

end
