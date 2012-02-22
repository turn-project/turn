require File.expand_path(File.dirname(__FILE__)) + '/helper.rb'
require File.expand_path(File.dirname(__FILE__) + '/..') + '/lib/turn/reporter'

class TestReporter < Turn::Reporter
end

class TestReporters < Test::Unit::TestCase
  def test_unit_test_files_are_filtered_but_project_files_are_not
    reporter = TestReporter.new(nil)
    
    # If you follow the convention of naming your test files with _test.rb, do not filter that
    # test file from the stack trace
    filtered_lines = ["/Users/testman/.rvm/rubies/ruby-1.9.3-p0/lib/ruby/1.9.1/test/unit/assertions.rb:185:in `assert_equal'"]
    unfiltered_lines = ["/Users/testman/source/campaign_manager/test/unit/omg_test.rb:145:in `block in <class:OmgTest>'", 
      "/Users/testman/source/campaign_manager/app/models/omg.rb:145:in `in double_rainbows'" ]
    stack_trace = filtered_lines + unfiltered_lines

    assert_equal unfiltered_lines, reporter.send(:filter_backtrace, stack_trace)
  end
end
