require 'minitest/unit'
require 'minitest/spec'
#require 'rubygems'
require 'turn/colorize'

class MiniTest::Unit
  PADDING_SIZE = 4
  
  @@use_natural_language_case_names = false
  def self.use_natural_language_case_names=(boolean)
    @use_natural_language_case_names = boolean
  end
  
  def self.use_natural_language_case_names?
    @use_natural_language_case_names
  end
  

  def run(args = [])
    @verbose = true

    # args[0] contains the path to test definitions (i.e. something
    # like "test/**/*_test.rb"). It does not look like a valid
    # command-line option to getopts() and causes it to stop processing
    # and just return. Remove it so that options like "name" and "trace"
    # are properly processed.
    # NOTE: I'd rather use Array.slice() here, but args returned
    # object does not have getopts() method.
    testopts = args.clone
    testopts.delete_at(0)

    options = testopts.getopts("n:", "name:", "notrace", "tracetype:")
    filter = if name = options["n"] || options["name"]
               if name =~ /\/(.*)\//
                 Regexp.new($1)
               elsif MiniTest::Unit.use_natural_language_case_names?
                 # Turn 'sample error1' into 'test_sample_error1'
                 name[0..4] == "test_" ? name.gsub(" ", "_") : "test_" + name.gsub(" ", "_")
               else
                 name
               end
             else
               /./ # anything - ^test_ already filtered by #tests
             end

    @trace = !options['notrace']
    @tracetype = options['tracetype'] || "application"

    @@out.puts "Loaded suite #{$0.sub(/\.rb$/, '')}\nStarted"

    start = Time.now
    run_test_suites filter

    @@out.puts
    @@out.puts "Finished in #{'%.6f' % (Time.now - start)} seconds."

    @@out.puts

    @@out.print "%d tests, " % test_count
    @@out.print "%d assertions, " % assertion_count
    @@out.print Turn::Colorize.fail("%d failures, " % failures)
    @@out.print Turn::Colorize.error("%d errors, " % errors)
    @@out.puts Turn::Colorize.skip("%d skips" % skips)

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

        @@out.print(case run_testcase(inst, self)
                    when :pass
                      @broken = false
                      Turn::Colorize.pass(pad_with_size "PASS")
                    when :error
                      @broken = true
                      Turn::Colorize.error(pad_with_size "ERROR")
                    when :fail
                      @broken = true
                      Turn::Colorize.fail(pad_with_size "FAIL")
                    when :skip
                      @broken = false
                      Turn::Colorize.skip(pad_with_size "SKIP")
                    end)


        @@out.print MiniTest::Unit.use_natural_language_case_names? ? 
          " #{test.gsub("test_", "").gsub(/_/, " ")}" : " #{test}"
        @@out.print " (%.2fs) " % (Time.now - t)

        if @broken
          @@out.puts

          report = @report.last
          @@out.puts pad(report[:message], 10)

          # If we're using Rails we can show only interesting for us part of the backtrace
          if defined?(Rails) && Rails.respond_to?(:backtrace_cleaner)
            case @tracetype
            when "application"
              filtered_backtrace = MiniTest::filter_backtrace(Rails.backtrace_cleaner.clean(report[:exception].backtrace, :silent))
            when "framework"
              filtered_backtrace = MiniTest::filter_backtrace(Rails.backtrace_cleaner.clean(report[:exception].backtrace, :noise))
            when "full"
              filtered_backtrace = MiniTest::filter_backtrace(report[:exception].backtrace)
            else
              @@out.puts "Unidentified trace type, setting to full"
              @@out.puts @tracetype
              filtered_backtrace = MiniTest::filter_backtrace(report[:exception].backtrace)
            end
          else
            filtered_backtrace = MiniTest::filter_backtrace(report[:exception].backtrace)
          end

          if @trace
            @@out.print filtered_backtrace.map{|t| pad(t, 10) }.join("\n")
          else
            @@out.print pad(filtered_backtrace.first, 10)
          end

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

private
  # A wrapper over MiniTest::Unit::TestCase.run() that returns
  # :pass whenever the test succeeds (i.e. run() returns "" or ".")
  def run_testcase(testcase, runner)
    original_result = testcase.run(runner)
    if original_result == "" || original_result == "."
        :pass
    else
        original_result
    end
  end
end

