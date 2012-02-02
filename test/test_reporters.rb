require File.expand_path(File.dirname(__FILE__)) + '/helper.rb'

class TestReporters < Test::Unit::TestCase

  begin
    require 'ansi'
    def test_progress
      file = setup_testunit
      result = turn '--progress', file
      assert(result.index('PASS'), result)
    end
  rescue LoadError
  end

  def test_dotted
    file = setup_testunit
    result = turn '--dotted', file
    assert result.index('0 failures'), "ACTUAL RESULT:\n#{result}"
    assert result.index('0 errors'), "ACTUAL RESULT:\n#{result}"
  end

  def test_marshal
    file = setup_testunit
    result = turn '--marshal', file
    assert !result.index('error: true'), "ACTUAL RESULT:\n#{result}"
    assert !result.index('fail: true'),  "ACTUAL RESULT:\n#{result}"
  end

  def test_outline
    file = setup_testunit_outline
    result = turn '--outline', file
    assert result.index('You should see me'), "ACTUAL RESULT:\n#{result}"
    assert !result.index('You should not see me'), "ACTUAL RESULT:\n#{result}"
  end

  def test_pretty
    file = setup_testunit
    result = turn '--pretty', file
    assert result.index('0 errors'), "ACTUAL RESULT:\n#{result}"
    assert result.index('0 failures'), "ACTUAL RESULT:\n#{result}"
  end

end

