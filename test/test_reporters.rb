require File.dirname(File.expand_path(__FILE__)) + '/helper.rb'

class TestReporters < Test::Unit::TestCase

  begin
    require 'ansi'
    def test_progress
      file = setup_test('Test')
      result = turn '--progress', file
      assert(result.index('PASS'), result)
    end
  rescue LoadError
  end

  def test_dotted
    file = setup_test('Test')
    result = turn '--dotted', file
    assert result.index('0 failures')
    assert result.index('0 errors')
  end

  def test_marshal
    file = setup_test('Test')
    result = turn '--marshal', file
    assert !result.index('error: true')
    assert !result.index('fail: true')
  end

  def test_outline
    file = setup_outline_test
    result = turn '--outline', file
    assert result.index('You should see me')
    assert !result.index('You should not see me')
  end

  def test_pretty
    file = setup_test('Test')
    result = turn '--pretty', file
    assert result.index('0 errors')
    assert result.index('0 failures')
  end

end

