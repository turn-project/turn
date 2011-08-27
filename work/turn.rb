require 'test/unit/ui/console/testrunner'
require 'turn/colorize'

require 'turn/components/suite.rb'
require 'turn/components/case.rb'
require 'turn/components/method.rb'

require 'turn/reporters/outline_reporter.rb'
require 'turn/reporters/progress_reporter.rb'

#$turn_reporter = Turn::ProgressReporter.new(@io)
$turn_reporter = Turn::OutlineReporter.new(@io)

module ::Test::Unit
module UI
module Console
  class TestRunner
    include Turn::Colorize

    # Is this needed?
    alias :t_attach_to_mediator :attach_to_mediator

    def attach_to_mediator
      @mediator.add_listener(TestRunnerMediator::STARTED, &method(:t_started))
      @mediator.add_listener(TestRunnerMediator::FINISHED, &method(:t_finished))
      @mediator.add_listener(TestSuite::STARTED, &method(:t_case_started))
      @mediator.add_listener(TestSuite::FINISHED, &method(:t_case_finished))
      @mediator.add_listener(TestCase::STARTED, &method(:t_test_started))
      @mediator.add_listener(TestCase::FINISHED, &method(:t_test_finished))
      @mediator.add_listener(TestResult::FAULT, &method(:t_fault))

      @io.sync    = true

      @t_result   = nil
      @t_fault    = nil
      @t_reporter = $turn_reporter

      @t_previous_run_count       = 0
      @t_previous_error_count     = 0
      @t_previous_failure_count   = 0
      @t_previous_assertion_count = 0
    end

    def t_started(result)
      @t_suite = Turn::TestSuite.new #@suite
      @t_suite.size = @suite.size
      @t_result = result
      @t_reporter.start_suite(@t_suite)
    end

    def t_case_started(name)
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
        msg = "\t"
        msg << fault.to_s.split("\n")[2..-1].join("\n\t")
        msg = ::ANSI::Code.magenta(msg) if colorize?
        @t_test.error!(msg)
        @t_reporter.error(msg)
      when ::Test::Unit::Failure
        msg = "\t"
        msg << fault.location[0] << "\n\t"
        msg << fault.message.gsub("\n","\n\t")
        msg = ::ANSI::Code.magenta(msg) if colorize?
        @t_test.fail!(msg)
        @t_reporter.fail(msg)
      end
    end

    def t_test_finished(name)
      @t_reporter.pass if @t_test.pass?
      @t_reporter.finish_test(@t_test)
    end

    def t_case_finished(name)
      t = @t_result.run_count       - @t_previous_run_count
      f = @t_result.failure_count   - @t_previous_failure_count
      e = @t_result.error_count     - @t_previous_error_count
      a = @t_result.assertion_count - @t_previous_assertion_count

      @t_case.counts(t,a,f,e)

      @t_previous_run_count       = @t_result.run_count
      @t_previous_failure_count   = @t_result.failure_count
      @t_previous_error_count     = @t_result.error_count
      @t_previous_assertion_count = @t_result.assertion_count

      @t_reporter.finish_case(@t_case)
    end

    def t_finished(elapsed_time)
      @t_suite.count_tests      = @t_result.run_count
      @t_suite.count_failures   = @t_result.failure_count
      @t_suite.count_errors     = @t_result.error_count
      @t_suite.count_passes     = @t_result.run_count - @t_result.failure_count - @t_result.error_count
      @t_suite.count_assertions = @t_result.assertion_count

      @t_reporter.finish_suite(@t_suite)
    end

  end
end
end
end

# EOF
