require 'test/unit'
#require 'turn'

class TC_Sample < Test::Unit::TestCase

  def test_sample_pass
    assert_equal(1,1)
  end

  def test_sample_fail
    assert_equal(1,2)
  end

end

