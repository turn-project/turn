class FooTest < MiniTest::Unit::TestCase
  def test_t1
    assert true
  end
end

class BarTest < MiniTest::Unit::TestCase
  def test_t2
    assert true
    assert true
  end
  def test_t3
    assert true
    assert false
  end
end

