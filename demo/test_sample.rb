class SampleTest < Test::Unit::TestCase

  def test_sample_pass
    assert_equal(1,1)
  end

  def test_sample_fail
    assert_equal(1,2)
  end

  def test_sample_error
    raise StandardError, "Raised exception!"
  end

end


class EmptyTest < Test::Unit::TestCase
end
