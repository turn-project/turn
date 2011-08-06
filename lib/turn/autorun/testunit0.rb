require 'test/unit/ui/console/testrunner'
require 'turn/colorize'

module ::Test::Unit
module UI
module Console
  class TestRunner
    include Turn::Colorize

    # 1.x of test/unut used @io, where as 2.x uses @output.
    def turn_out
      @turn_out ||= (@io || @output)
    end

    alias :t_attach_to_mediator :attach_to_mediator
    def attach_to_mediator
      @mediator.add_listener(TestRunnerMediator::STARTED, &method(:t_started))
      @mediator.add_listener(TestRunnerMediator::FINISHED, &method(:t_finished))
      @mediator.add_listener(TestCase::STARTED, &method(:t_test_started))
      @mediator.add_listener(TestCase::FINISHED, &method(:t_test_finished))
      @mediator.add_listener(TestResult::FAULT, &method(:t_fault))
      turn_out.sync = true
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
        bar = if pass == total then ::ANSI::Code.green{bar}
              else ::ANSI::Code.red{bar} end
      end

      turn_out.puts bar
      turn_out.puts "  pass: %d,  fail: %d,  error: %d" % [pass, failure, error]
      turn_out.puts "  total: %d tests with %d assertions in #{elapsed_time} seconds" % [total, @t_result.assertion_count]
      turn_out.puts bar
    end

    def t_test_started( name )
      method, file = name.scan(%r/^([^\(]+)\(([^\)]+)\)/o).flatten!
      if @t_cur_file != file
        @t_cur_file = file
        file = COLORIZE ? ::ANSI::Code.yellow{file} : file
        turn_out.puts file
      end
      turn_out.print "    %-69s" % method
    end

    def t_test_finished( name )
      turn_out.puts " #{PASS}" unless @t_fault
      @t_fault = false
    end

    def t_fault( fault )
      @t_fault = true
      msg = "\t"

      case fault
      when ::Test::Unit::Error
        turn_out.puts ERROR
        msg << fault.to_s.split("\n")[2..-1].join("\n\t")
      when ::Test::Unit::Failure
        test_name =  underscore(fault.test_name.match(/\((.*)\)/)[1])
        better_location = fault.location.detect{|line|line.include?(test_name)} || fault.location[0]
        turn_out.puts " #{FAIL}"
        msg << better_location.to_s << "\n\t"
        msg << fault.message.gsub("\n","\n\t")
      end

      msg = ::ANSI::Code.magenta{msg} if COLORIZE
      turn_out.puts msg
    end

    private

    # Taken from ActiveSupport::Inflector
    def underscore(camel_cased_word)
      word = camel_cased_word.to_s.dup
      word.gsub!(/::/, '/')
      word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      word.tr!("-", "_")
      word.downcase!
      word
    end

    def setup_mediator
       @mediator = create_mediator(@suite)
       suite_name = @suite.to_s
       if ( @suite.kind_of?(Module) )
         suite_name = @suite.name
       end
       msg = rails? ? "\n" : "Loaded suite #{suite_name}" #always same in rails so scrap it
       output(msg)
    end

    def rails?
      $:.to_s.include? "rails"
    end


  end
end
end
end

# EOF
