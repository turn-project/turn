require File.dirname(__FILE__) + '/helper.rb'

class TestRunners < Test::Unit::TestCase

  def test_solo
    setup_test('Test')
    result = `turn --solo tmp/test.rb`
    assert result.index('fail: 0')
    assert result.index('error: 0')
  end

  def test_cross
    setup_test('Test', false, 'test1.rb')
    setup_test('Test', false, 'test2.rb')
    result = `turn --cross tmp/test1.rb tmp/test2.rb`
    assert !result.index('FAIL')
  end

end

