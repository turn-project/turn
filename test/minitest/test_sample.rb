class TC_Sample < MiniTest::Unit::TestCase

  def test_sample_pass
    puts "You should not see me"
    assert_equal(1,1)
  end

  def test_sample_fail
    puts "You should see me"
    assert_equal(1,2)
  end

end

