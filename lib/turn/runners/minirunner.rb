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

      return failures + errors if @test_count > 0 # or return nil...
    end

    #
    def run_test_suites(filter = /./)
      @test_count, @assertion_count = 0, 0
      old_sync, @@out.sync = @@out.sync, true if @@out.respond_to? :sync=

      @turn_suite = Turn::TestSuite.new(@turn_suite_name)
      @turn_suite.size = ::MiniTest::Unit::TestCase.test_suites.size
      @turn_logger.start_suite(@turn_suite)

      ::MiniTest::Unit::TestCase.test_suites.each do |kase|

        test_cases = kase.test_methods.grep(filter)

        @turn_case = @turn_suite.new_case(kase.name)

        turn_cases = test_cases.map do |test|
          @turn_case.new_test(test)
        end

        @turn_logger.start_case(@turn_case)

        turn_cases.each do |test|
          #methname, tcase = name.scan(%r/^([^\(]+)\(([^\)]+)\)/o).flatten!
          @turn_test = test #@turn_case.new_test(test)
          @turn_logger.start_test(@turn_test)

          inst = kase.new(test.name)
          inst._assertions = 0

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
      self.__send__(self.__name__.to_s)
      @passed = true
    rescue Exception => e
      @passed = false
      result = runner.puke(self.class, self.__name__.to_s, e)
    ensure
      begin
        self.teardown
      rescue Exception => e
        result = runner.puke(self.class, self.__name__.to_s, e)
      end
    end
    result
  end
end

