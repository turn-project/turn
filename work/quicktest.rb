# Christian Neukirchen

# This could actually be quite usable if it weren't for one small problem:
# There is no way to close off blocks from the outside scope.
# This can cause interferance between separate tests.
# So while quicktest works for simple cases, it may well run into
# problems with anything sizable.

require 'test/unit'

$TCGEN = "000000"
$TGEN  = "000000"

#$TS = []
$TC = [nil]

def testcase(name=nil, &block)
  tc = Class.new(Test::Unit::TestCase)
  #self.class.const_set("TC_#{(name||$TCGEN.succ!)}", tc)
  $TC << tc
  tc.class_eval &block
end

class Test::Unit::TestCase
  def self.gen_test_name
    @gen_test_name ||= "000000"
    @gen_test_name.succ!
    return "#{@gen_test_name}"
  end
  def self.test(name=nil, &block)
    __send__(:define_method, "test_#{(name||gen_test_name)}", &block)
  end
end

def test(name=nil, &block)
  $TC[0] ||= Class.new(Test::Unit::TestCase)
  self.class.const_set("TC#{$TCGEN.succ!}", $TC[0])
  $TC[0].__send__(:define_method, "test_#{(name||$TGEN.succ!)}", &block)
end


#Test::Unit.run = !$DEBUG
