require 'turn/testunit'

class SampleCase1 < Test::Unit::TestCase
  def test_sample_pass1
    assert_equal(1,1)
  end
  def test_sample_pass2
    assert_equal(2,2)
  end

  def test_sample_fail1
    assert_equal(1,2)
  end
  def test_sample_fail2
    assert_include(1,[])
  end

  def test_sample_error1
    raise StandardError, "Raised exception!"
  end
  def test_sample_error2
    raise StandardError, "Raised another exception!"
  end
end

