$:.unshift './lib'

#require 'turn/colorize'
require 'fileutils'

if RUBY_VERSION < "1.9"
  require 'test/unit'
else
  require 'minitest/unit'
  require 'test/unit'
end

#
#Turn.config.format = :pretty

#
def turn(*args)
  `ruby -Ilib bin/turn -Ilib #{args.join(' ')} 2>&1`
end

#
def turn2(*args)
  `ruby -Ilib bin/turn -Ilib #{args.join(' ')}`
end

def turn_with_term(term, *args)
  `TERM="#{term}" ruby -Ilib bin/turn -Ilib #{args.join(' ')} 2>&1`
end

#
def setup_test(framework, required=false, name=nil)
  text = ''
  text << "require '#{required}'\n" if required
  text << <<-HERE
class TestTest < #{framework}::Unit::TestCase
#{standard_test_body}
end
  HERE
  #name = framwwork.downcase
  #name = name + '_required' if requires
  save_test(text, name)
end

#
def save_test(text, name=nil)
  file = File.join('tmp', name || 'test.rb')
  FileUtils.mkdir_p('tmp') unless File.directory?('tmp')
  File.open(file, 'w'){ |f| f << text }
  return file
end

#
def standard_test_body
<<-HERE
  def test_pass
    assert_equal(1,1)
  end
HERE
end

#
def guanlent_test_body
<<-HERE
  def test_pass
    assert_equal(1,1)
  end

  def test_fail
    assert_equal(1,2)
  end

  def test_error
    raise
  end
HERE
end

#
def setup_outline_test
  text = <<-HERE
class OutlineTest < Test::Unit::TestCase
  def test_sample_pass
    puts "You should not see me"
    assert_equal(1,1)
  end
  def test_sample_fail
    puts "You should see me"
    assert_equal(1,2)
  end
end
  HERE
  save_test(text, 'outline_test.rb')
end

#
def setup_minitest_autorun
  text = <<-HERE
require 'turn'
MiniTest::Unit.runner = Turn::MiniRunner.new
MiniTest::Unit.autorun
#require 'minitest/unit'
class TestTest < MiniTest::Unit::TestCase
  def test_sample_pass
    assert_equal(1,1)
  end
end
  HERE
  save_test(text, 'minitest_autorun_test.rb')
end


def setup_minitest_autorun_with_trace
  text = <<-HERE
#require 'minitest/unit'
#require 'rubygems'
require 'turn'
MiniTest::Unit.runner = Turn::MiniRunner.new
MiniTest::Unit.autorun
Turn.config do |c|
  c.trace = 1
end
class TestTest < MiniTest::Unit::TestCase
  def test_sample_pass
    assert_equal(0,1)
  end
end
  HERE
  save_test(text, 'minitest_autorun_test_with_fail.rb')
end
