require 'minitest/unit'

Test = MiniTest

module Turn

  # = MiniTest TestRunner
  #
  class MiniRunner < ::MiniTest::Unit

    #
    def initialize(controller)

      controller.loadpath.each{ |path| $: << path } unless controller.live?
      controller.requires.each{ |path| require(path) }

      [controller.files].flatten.each{ |path| require(path) }

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
    end

    #
    def start(args=[])
      run(args)
      return @turn_suite
    end

    #
    def run(args = [])
      @verbose = true

      filter = if args.first =~ /^(-n|--name)$/ then
                 args.shift
                 arg = args.shift
                 arg =~ /\/(.*)\// ? Regexp.new($1) : arg
               else
                 /./ # anything - ^test_ already filtered by #tests
               end

      #@@out.puts "Loaded suite #{$0.sub(/\.rb$/, '')}\nStarted"

      start = Time.now

      run_test_suites(filter)

      #@@out.puts
      #@@out.puts "Finished in #{'%.6f' % (Time.now - start)} seconds."

      #@@out.puts

      #@@out.print "%d tests, " % test_count
      #@@out.print "%d assertions, " % assertion_count
      #@@out.print red { "%d failures, " % failures }
      #@@out.print yellow { "%d errors, " % errors }
      #@@out.puts cyan { "%d skips" % skips}

      return failures + errors if @test_count > 0 # or return nil...
    end

    # NOTES: MiniTest somehow manages to confuse a suite for a case, and a case for a unit test.
    def run_test_suites(filter = /./)
      @test_count, @assertion_count = 0, 0
      old_sync, @@out.sync = @@out.sync, true if @@out.respond_to? :sync=

      @turn_suite = Turn::TestSuite.new #@suite
      @turn_suite.size = ::MiniTest::Unit::TestCase.test_suites.size
      @turn_logger.start_suite(@turn_suite)

      ::MiniTest::Unit::TestCase.test_suites.each do |suite|
        test_cases = suite.test_methods.grep(filter)

        @turn_case = @turn_suite.new_case(suite.name)
        @turn_logger.start_case(@turn_case)

        #if test_cases.size > 0
        #  @@out.print "\n#{suite}:\n"
        #end

        test_cases.each do |test|
          #methname, tcase = name.scan(%r/^([^\(]+)\(([^\)]+)\)/o).flatten!
          @turn_test = @turn_case.new_test(test)
          @turn_logger.start_test(@turn_test)

          inst = suite.new(test)
          inst._assertions = 0

          #t = Time.now

          #@broken = nil

          #@@out.print(case inst.run(self)
          #            when :pass
          #              @broken = false
          #              green { pad_with_size "PASS" }
          #            when :error
          #              @broken = true
          #              yellow { pad_with_size "ERROR" }
          #            when :fail
          #              @broken = true
          #              red { pad_with_size "FAIL" }
          #            when :skip
          #              @broken = false
          #              cyan { pad_with_size "SKIP" }
          #            end)

          result = inst.run(self)
          report = @report.last

          case result
          when :pass
            @turn_logger.pass
          when :error
            #trace = ::MiniTest::filter_backtrace(report[:exception].backtrace).first
            @turn_test.error!(report)
            @turn_logger.error(report)
          when :fail
            #trace = ::MiniTest::filter_backtrace(report[:exception].backtrace).first
            @turn_test.fail!(report)
            @turn_logger.fail(report)
          when :skip
            @turn_test.skip! #(report)
            @turn_logger.skip #(report)
          end

          #@@out.print " #{test}"
          #@@out.print " (%.2fs) " % (Time.now - t)

          #if @broken
            #@@out.puts
            #report = @report.last
            #@@out.puts pad(report[:message], 10)
            #trace = MiniTest::filter_backtrace(report[:exception].backtrace).first
            #@@out.print pad(trace, 10)

          #  @@out.puts
          #end

          @turn_logger.finish_test(@turn_test)

          @test_count += 1
          @assertion_count += inst._assertions
        end
        @turn_logger.finish_case(@turn_case)
      end
      @turn_logger.finish_suite(@turn_suite)
      @@out.sync = old_sync if @@out.respond_to? :sync=
      [@test_count, @assertion_count]
    end

    #def pad(str, size=PADDING_SIZE)
    #  " " * size + str
    #end

    #def pad_with_size(str)
    #  pad("%5s" % str)
    #end

    # Overwrite #puke method so that is stores a hash
    # with :message and :exception keys.
    def puke(klass, meth, e)
      result = nil
      msg = case e
          when ::MiniTest::Skip
            @skips += 1
            result = :skip
            e.message
          when ::MiniTest::Assertion
            @failures += 1
            result = :fail
            e.message
          else
            @errors += 1
            result = :error
            "#{e.class}: #{e.message}\n"
          end

      @report << e #{:message => msg, :exception => e}
      result
    end

  end

end

class ::MiniTest::Unit::TestCase
  # Overwrite #run method so that is uses symbols
  # as return values rather than characters.
  def run(runner)
    result = :pass
    begin
      @passed = nil
      self.setup
      self.__send__(self.__name__)
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

