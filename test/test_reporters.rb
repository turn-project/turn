require File.dirname(__FILE__) + '/helper.rb'

class TestRunners < Test::Unit::TestCase

  def test_progress
    setup_test('Test')
    result = `turn --progress tmp/test.rb 2>&1`
    assert result.index('PASS')
  end

  def test_dotted
    setup_test('Test')
    result = `turn --dotted tmp/test.rb`
    assert result.index('0 failures')
    assert result.index('0 errors')
  end

  def test_marshal
    setup_test('Test')
    result = `turn --marshal tmp/test.rb`
    assert !result.index('error: true')
    assert !result.index('fail: true')
  end

end

