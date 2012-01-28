require File.expand_path(File.dirname(__FILE__)) + '/helper.rb'

class TestRunners < Test::Unit::TestCase

  def test_solo
    file = setup_test('Test', false, 'test_solo.rb')
    result = turn2 '--solo', file
    assert result.index('pass: 1')
    assert result.index('fail: 0')
    assert result.index('error: 0')
  end

  def test_cross
    file1 = setup_test('Test', false, 'test1.rb')
    file2 = setup_test('Test', false, 'test2.rb')
    result = turn2 '--cross', file1, file2
    assert result.index('pass: 2')
    assert result.index('error: 0')
  end

  # autorun

  #if RUBY_VERSION < '1.9'
  #
  #  def test_autorun
  #    file = setup_test('Test', 'turn/autorun', 'test_autorun.rb')
  #    result = `ruby -Ilib #{file} 2>&1`
  #    assert(result.index('pass: 1'))
  #    assert(result.index('fail: 0'))
  #    assert(result.index('error: 0'))
  #  end
  #
  #else

    def test_autorun
      file = setup_minitest_autorun
      result = `ruby -Ilib #{file} 2>&1`
      assert result.index('fail: 0'),  "ACTUAL RESULT --->\n #{result}"
      assert result.index('error: 0'), "ACTUAL RESULT --->\n #{result}"
    end

    def test_autorun_with_trace
      file = setup_minitest_autorun_with_trace

      result = `ruby -Ilib #{file} 2>&1`
      assert result.index('fail: 1'), 'fail is not 1'
      assert result.index('error: 0'), 'error is not 0'

      # TODO: the backtrace is empty, why?
      #assert result.scan(/\.rb:\d+:in/).length > 1
    end

  #end

end

