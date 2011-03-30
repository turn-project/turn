require 'minitest/unit'
require 'minitest/spec'
#require 'rubygems'
require 'ansi'

class MiniTest::Unit
  include ANSI::Code

  PADDING_SIZE = 4

  def run(args = [])
    @verbose = true

    filter = if args.first =~ /^(-n|--name)$/ then
               args.shift
               arg = args.shift
               if arg =~ /\/(.*)\//
                 Regexp.new($1)
               else
                 # Turn 'sample error1' into 'test_sample_error1'
                 arg[0..4] == "test_" ? arg.gsub(" ", "_") : "test_" + arg.gsub(" ", "_")
               end
             else
               /./ # anything - ^test_ already filtered by #tests
             end

    @@out.puts "Loaded suite #{$0.sub(/\.rb$/, '')}\nStarted"

    start = Time.now
    run_test_suites filter

    @@out.puts
    @@out.puts "Finished in #{'%.6f' % (Time.now - start)} seconds."

    @@out.puts

    @@out.print "%d tests, " % test_count
    @@out.print "%d assertions, " % assertion_count
    @@out.print red { "%d failures, " % failures }
    @@out.print yellow { "%d errors, " % errors }
    @@out.puts cyan { "%d skips" % skips}

    return failures + errors if @test_count > 0 # or return nil...
  end

  # Overwrite #run_test_suites so that it prints out reports
  # as errors are generated.
  def run_test_suites(filter = /./)
    @test_count, @assertion_count = 0, 0
    old_sync, @@out.sync = @@out.sync, true if @@out.respond_to? :sync=
    TestCase.test_suites.each do |suite|
      test_cases = suite.test_methods.grep(filter)
      if test_cases.size > 0
        @@out.print "\n#{suite}:\n"
      end

      test_cases.each do |test|
        inst = suite.new test
        inst._assertions = 0

        t = Time.now

        @broken = nil

        @@out.print(case inst.run(self)
                    when :pass
                      @broken = false
                      green { pad_with_size "PASS" }
                    when :error
                      @broken = true
                      yellow { pad_with_size "ERROR" }
                    when :fail
                      @broken = true
                      red { pad_with_size "FAIL" }
                    when :skip
                      @broken = false
                      cyan { pad_with_size "SKIP" }
                    end)


        @@out.print " #{test.gsub("test_", "").gsub(/_/, " ")}"
        @@out.print " (%.2fs) " % (Time.now - t)

        if @broken
          @@out.puts

          report = @report.last
          @@out.puts pad(report[:message], 10)
          trace = MiniTest::filter_backtrace(report[:exception].backtrace).first
          @@out.print pad(trace, 10)

          @@out.puts
        end

        @@out.puts
        @test_count += 1
        @assertion_count += inst._assertions
      end
    end
    @@out.sync = old_sync if @@out.respond_to? :sync=
    [@test_count, @assertion_count]
  end

  def pad(str, size=PADDING_SIZE)
    " " * size + str
  end

  def pad_with_size(str)
    pad("%5s" % str)
  end

  # Overwrite #puke method so that is stores a hash
  # with :message and :exception keys.
  def puke(klass, meth, e)
    result = nil
    msg = case e
        when MiniTest::Skip
          @skips += 1
          result = :skip
          e.message
        when MiniTest::Assertion
          @failures += 1
          result = :fail
          e.message
        else
          @errors += 1
          result = :error
          "#{e.class}: #{e.message}\n"
        end

    @report << {:message => msg, :exception => e}
    result
  end


  class TestCase
    # Overwrite #run method so that is uses symbols
    # as return values rather than characters.
    def run(runner)
      result = :pass
      begin
        @passed = nil
        self.setup
        self.__send__ self.__name__
        @passed = true
      rescue Exception => e
        @passed = false
        result = runner.puke(self.class, self.__name__, e)
      ensure
        begin
          self.teardown
        rescue Exception => e
          result = runner.puke(self.class, self.__name__, e)
        end
      end
      result
    end
  end
end

