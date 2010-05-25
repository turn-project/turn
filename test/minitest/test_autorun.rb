require 'turn' unless defined? Turn
if Turn.minitest?

class TC_Example < MiniTest::Unit::TestCase

  def test_example_pass
    assert_equal(4,4)
  end

  def test_example_fail
    assert_equal(2,3)
  end

end

end
