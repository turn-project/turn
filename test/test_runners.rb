require File.dirname(__FILE__) + '/helper.rb'

class TestRunners < Test::Unit::TestCase

  def test_solo
    file = setup_test('Test', false, 'test_solo.rb')
    result = turn '--solo', file
    assert result.index('fail: 0')
    assert result.index('error: 0')
  end

  def test_cross
    file1 = setup_test('Test', false, 'test1.rb')
    file2 = setup_test('Test', false, 'test2.rb')
    result = turn '--cross', file1, file2
    assert !result.index('FAIL')
  end

  # autorun

  if RUBY_VERSION < '1.9'

    def test_autorun
      file = setup_test('Test', 'test/unit', 'test_autorun.rb')
      result = `ruby #{file} 2>&1`
      assert result.index('0 failures')
      assert result.index('0 errors')
    end

  else

    def test_autorun
      file = setup_minitest_autorun
      result = `ruby #{file} 2>&1`
      assert result.index('0 failures')
      assert result.index('0 errors')
    end

  end

end

