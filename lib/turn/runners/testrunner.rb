#require 'test/unit'; Test::Unit.run = false
require 'test/unit/ui/console/testrunner'

#require 'turn/colorize'
#require 'turn/components/suite.rb'
#require 'turn/components/case.rb'
#require 'turn/components/method.rb'
#require 'turn/reporters/outline_reporter.rb'
#require 'turn/reporters/progress_reporter.rb'

class Test::Unit::Failure
  alias_method :backtrace, :location
end

module Turn

  # = TestUnit TestRunner
  #
  class TestRunner < ::Test::Unit::UI::Console::TestRunner

    def initialize(controller)
      output_level = 2 # 2-NORMAL 3-VERBOSE

      controller.loadpath.each{ |path| $: << path } unless controller.live?
      controller.requires.each{ |path| require(path) }

      files = [controller.files].flatten
      files.each{ |path| require(path) }   

      # TODO: Better name ?
      name = files.map{ |path| File.dirname(path).sub(Dir.pwd+'/','') }.uniq.join(',')

      sub_suites = []
      ObjectSpace.each_object(Class) do |klass|
        if(Test::Unit::TestCase > klass)
          sub_suites << klass.suite
        end
      end
      suite = Test::Unit::TestSuite.new(name)

      sub_suites.sort_by{|s|s.name}.each{|s| suite << s}

      suite.tests.each do |c|
        pattern = controller.pattern
        c.tests.reject! { |t| pattern !~ t.method_name }
      end

      @t_reporter = controller.reporter

      super(suite, output_level, $stdout)
    end

    # Is this needed?
    alias :t_attach_to_mediator :attach_to_mediator

    def attach_to_mediator
      @mediator.add_listener(::Test::Unit::UI::TestRunnerMediator::STARTED, &method(:t_started))
      @mediator.add_listener(::Test::Unit::UI::TestRunnerMediator::FINISHED, &method(:t_finished))
      @mediator.add_listener(::Test::Unit::TestSuite::STARTED, &method(:t_case_started))
      @mediator.add_listener(::Test::Unit::TestSuite::FINISHED, &method(:t_case_finished))
      @mediator.add_listener(::Test::Unit::TestCase::STARTED, &method(:t_test_started))
      @mediator.add_listener(::Test::Unit::TestCase::FINISHED, &method(:t_test_finished))
      @mediator.add_listener(::Test::Unit::TestResult::FAULT, &method(:t_fault))

      @io.sync    = true

      @t_result   = nil
      @t_fault    = nil

      @not_first_case = nil

      @t_previous_run_count       = 0
      @t_previous_error_count     = 0
      @t_previous_failure_count   = 0
      @t_previous_assertion_count = 0
    end

    def t_started(result)
      @t_suite = Turn::TestSuite.new(@suite.name)
      @t_suite.size = @suite.size
      @t_result = result
      @t_reporter.start_suite(@t_suite)
    end

    def t_case_started(name)
      # Err.. why is testunit running this on the suite?
      (@not_first_case = true; return) unless @not_first_case
      @t_case = @t_suite.new_case(name)
      @t_reporter.start_case(@t_case)
    end

    def t_test_started(name)
      methname, tcase = name.scan(%r/^([^\(]+)\(([^\)]+)\)/o).flatten!
      @t_test = @t_case.new_test(methname)
      #@t_test.file = tcase
      #@t_test.name = method
      @t_reporter.start_test(@t_test)
    end

    def t_fault(fault)
      case fault
      when ::Test::Unit::Error
        #msg = ""
        #msg << fault.to_s.split("\n")[2..-1].join("\n")
        @t_test.error!(fault.exception)
        @t_reporter.error(fault.exception)
      when ::Test::Unit::Failure
        #msg = ""
        #msg << fault.location[0] << "\n"
        #msg << fault.message #.gsub("\n","\n")
        @t_test.fail!(fault)
        @t_reporter.fail(fault)
      end
    end

    def t_test_finished(name)
      @t_reporter.pass if @t_test.pass?
      @t_reporter.finish_test(@t_test)
    end

      def t_case_finished(name)
      # Err.. why is testunit running this on the suite?
      return if name=='' # FIXME skip suite call

      #t = @t_result.run_count       - @t_previous_run_count
      #f = @t_result.failure_count   - @t_previous_failure_count
      #e = @t_result.error_count     - @t_previous_error_count
      a = @t_result.assertion_count - @t_previous_assertion_count
      #@t_case.counts(t,a,f,e)

      @t_case.count_assertions = a

      #@t_previous_run_count       = @t_result.run_count.to_i
      #@t_previous_failure_count   = @t_result.failure_count.to_i
      #@t_previous_error_count     = @t_result.error_count.to_i
      @t_previous_assertion_count = @t_result.assertion_count.to_i

      @t_reporter.finish_case(@t_case)
    end

    def t_finished(elapsed_time)
      #@t_suite.count_tests      = @t_result.run_count
      #@t_suite.count_failures   = @t_result.failure_count
      #@t_suite.count_errors     = @t_result.error_count
      #@t_suite.count_passes     = @t_result.run_count - @t_result.failure_count - @t_result.error_count
      @t_suite.count_assertions = @t_result.assertion_count

      @t_reporter.finish_suite(@t_suite)
    end

    # This is copied verbatim from test/unit/ui/console/testrunner.rb.
    # It is here for one simple reason: to supress testunits output of
    # "Loaded Suite".
    def setup_mediator
      @mediator = create_mediator(@suite)
      suite_name = @suite.to_s
      if ( @suite.kind_of?(Module) )
        suite_name = @suite.name
      end
      #output("Loaded suite #{suite_name}")
    end

  end#class TestRunner

end#module Turn

