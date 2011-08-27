require 'turn/reporter'

module Turn

  # = Cue Reporter
  #
  # Inspired by Shindo.
  #
  class CueReporter < Reporter

    def start_suite(suite)
      @suite = suite
      @time  = Time.now
      @stdout = StringIO.new
      @stderr = StringIO.new
      #files = suite.collect{ |s| s.file }.join(' ')
      io.puts "Loaded suite #{suite.name}"
      #io.puts "Started"
    end

    def start_case(kase)
      io.puts(kase.name)
    end

    def start_test(test)
      #if @file != test.file
      #  @file = test.file
      #  io.puts(test.file)
      #end
      io.print Colorize.blue("    %-69s" % test.name)
      $stdout = @stdout
      $stderr = @stderr
      $stdout.rewind
      $stderr.rewind
    end

    def pass(message=nil)
      io.puts " #{PASS}"
      if message
        message = Colorize.green(message)
        message = message.to_s.tabto(8)
        io.puts(message)
      end
    end

    def fail(assertion, message=nil)
      io.puts(" #{FAIL}")
      #message = assertion.location[0] + "\n" + assertion.message #.gsub("\n","\n")
      message = message || assertion.to_s
      #if message
        message = Colorize.red(message)
        message = message.to_s.tabto(8)
        io.puts(message)
      #end

      show_captured_output

      prompt
    end

    def error(exception, message=nil)
      #message = exception.to_s.split("\n")[2..-1].join("\n")
      message = message || exception.to_s
      io.puts("#{ERROR}")
      io.puts(message) #if message

      prompt
    end

    def finish_test(test)
      $stdout = STDOUT
      $stderr = STDERR
    end

    def show_captured_output
      show_captured_stdout
      show_captured_stderr
    end

    def show_captured_stdout
      @stdout.rewind
      return if @stdout.eof?
      STDOUT.puts(<<-output.tabto(8))
\nSTDOUT:
#{@stdout.read}
      output
    end

    def show_captured_stderr
      @stderr.rewind
      return if @stderr.eof?
      STDOUT.puts(<<-output.tabto(8))
\nSTDERR:
#{@stderr.read}
      output
    end

    #def finish_case(kase)
    #end

    def finish_suite(suite)
      total   = suite.count_tests
      failure = suite.count_failures
      error   = suite.count_errors
      pass    = total - failure - error

      bar = '=' * 78
      if colorize?
        bar = if pass == total then Colorize.green(bar)
              else Colorize.red(bar) end
      end

      tally = [total, suite.count_assertions]

      io.puts bar
      io.puts "  pass: %d,  fail: %d,  error: %d" % [pass, failure, error]
      io.puts "  total: %d tests with %d assertions in #{Time.new - @time} seconds" % tally
      io.puts bar
    end

    private

    def prompt
      begin
        io << "  [c,i,q,r,t,#,?] "
        io.flush
        until inp = $stdin.gets ; sleep 1 ; end
        answer = inp.strip
        case answer
        when 'c', ''
        when 'r'
          # how to reload and start over?
        when 'i'
          # how to drop into an interactive console?
        when 't'
          io.puts $@
          raise ArgumentError
        when /^\d+$/
          io.puts $@[0..answer.to_i]
          raise ArgumentError
        when 'q'
          exit -1
        when '?'
          io.puts HELP
          raise ArgumentError #prompt
        else
          raise ArgumentError
        end
      rescue ArgumentError
        retry
      end
    end

    HELP = %{
      c continue
      r restart
      i irb
      t backtrace
      # backtrace lines
      q quit
      ? help
    }

  end

end

