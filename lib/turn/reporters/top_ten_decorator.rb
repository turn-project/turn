
module Turn
  class TopTenDecorator
    def initialize(reporter)
      @reporter = reporter
    end

    def method_missing(m,*args,&block)
      @reporter.send(m,*args,&block)
    end

    def start_case(kase)
      @reporter.start_case(kase)
      @top_ten_current_case = kase
    end

    def start_test(test)
      @reporter.start_test(test)
      test_time_data[test_key(test)] = {:start => Time.now}
    end

    def finish_test(test)
      @reporter.finish_test(test)
      test_time_data[test_key(test)][:end] = Time.now
    end

    def finish_suite(suite)
      @reporter.finish_suite(suite)
      io.puts
      io.puts Colorize.bold("Top 10 Longest Running Tests")
      top_ten_times.each do |(test_name, time)|
        io.print format_time(time)
        io.puts format_test_name(test_name, time)
      end
      io.puts
    end

    private

    def test_key(test)
      "#{@top_ten_current_case.name} #{test}"
    end

    def top_ten_times
      test_times.sort_by {|(_, time)| -time}.take(10)
    end

    def test_times
      test_time_data.map {|(test, times)| [test, times[:end] - times[:start]]}
    end

    def test_time_data
      @test_time_data ||= {}
    end

    def format_time(time)
      Colorize.blue(time)
    end

    def format_test_name(test_name, time)
      test_name.tabto(11-time.to_s.length)
    end
  end
end
