# $Id$

require 'test/unit/ui/console/testrunner'
begin
  require 'facets/ansicode'
rescue LoadError
  begin
    require 'rubygems'
    require 'facets/ansicode'
  rescue LoadError
  end
end


module ::Test::Unit
module UI
module Console
  class TestRunner

    alias :t_attach_to_mediator :attach_to_mediator
    def attach_to_mediator
      @mediator.add_listener(TestRunnerMediator::STARTED, &method(:t_started))
      @mediator.add_listener(TestRunnerMediator::FINISHED, &method(:t_finished))
      @mediator.add_listener(TestCase::STARTED, &method(:t_test_started))
      @mediator.add_listener(TestCase::FINISHED, &method(:t_test_finished))
      @mediator.add_listener(TestResult::FAULT, &method(:t_fault))
      @io.sync = true
      @t_cur_file, @t_fault = nil
    end

    def t_started( result )
      @t_result = result
    end

    def t_finished( elapsed_time )
      failure = @t_result.failure_count
      error   = @t_result.error_count
      total   = @t_result.run_count
      pass = total - failure - error

      bar = '=' * 78
      if COLORIZE
        bar = if pass == total then ::Console::ANSICode.green bar
              else ::Console::ANSICode.red bar end
      end

      @io.puts bar
      @io.puts "  pass: %d,  fail: %d,  error: %d" % [pass, failure, error]
      @io.puts "  total: %d tests with %d assertions in #{elapsed_time} seconds" % [total, @t_result.assertion_count]
      @io.puts bar
    end

    def t_test_started( name )
      method, file = name.scan(%r/^([^\(]+)\(([^\)]+)\)/o).flatten!
      if @t_cur_file != file
        @t_cur_file = file
        @io.puts file
      end
      @io.print "    %-69s" % method
    end

    def t_test_finished( name )
      @io.puts PASS unless @t_fault
      @t_fault = false
    end

    def t_fault( fault )
      @t_fault = true
      msg = "\t"

      case fault
      when ::Test::Unit::Error
        @io.puts ERROR
        msg << fault.to_s.split("\n")[2..-1].join("\n\t")
      when ::Test::Unit::Failure
        @io.puts FAIL
        msg << fault.location[0] << "\n\t"
        msg << fault.message.gsub("\n","\n\t")
      end

      msg = ::Console::ANSICode.magenta msg if COLORIZE
      @io.puts msg
    end

    COLORIZE = defined?(::Console::ANSICode) && ENV.has_key?('TERM')
    if COLORIZE
      PASS = ::Console::ANSICode.green ' PASS'
      FAIL = ::Console::ANSICode.red ' FAIL'
      ERROR = ::Console::ANSICode.white(
              ::Console::ANSICode.on_red('ERROR'))
    else
      PASS = " PASS"
      FAIL = " FAIL"
      ERROR = "ERROR"
    end
  end
end
end
end

# EOF
