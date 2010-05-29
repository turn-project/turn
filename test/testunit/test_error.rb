class TestError < Test::Unit::TestCase

  def test_error1
    raise StandardError
  end

  def test_error2
    raise Exception
  end

end

