require File.expand_path(File.dirname(__FILE__)) + '/helper.rb'

# Test on Ruby 1.9+
if RUBY_VERSION >= '1.9'

  class TestRuby19Framework < MiniTest::Unit::TestCase

    def test_ruby19_minitest
      setup_test('MiniTest')
      result = turn 'tmp/test.rb'
      assert result.index('PASS')
      assert result.index('[0m')
    end

    def test_ruby19_minitest_without_color_on_dumb_terminal
      setup_test('MiniTest')
      result = turn_with_term 'dumb', 'tmp/test.rb'
      assert !result.index('[0m')
    end

    def test_ruby19_minitest_force
      setup_test('MiniTest')
      result = turn '--minitest tmp/test.rb'
      assert result.index('PASS')
    end

    def test_ruby19_minitest_required
      setup_test('MiniTest', 'minitest/unit')
      result = turn 'tmp/test.rb'
      assert result.index('PASS')
    end

    def test_ruby19_minitest_required_force
      setup_test('MiniTest', 'minitest/unit')
      result = turn '--minitest tmp/test.rb'
      assert result.index('PASS')
    end

    def test_ruby19_minitest_mocking
      setup_test('Test')
      result = turn 'tmp/test.rb'
      assert result.index('PASS')
    end

    def test_ruby19_minitest_mocking_force
      setup_test('Test')
      result = turn '--minitest tmp/test.rb'
      assert result.index('PASS')
    end

    def test_ruby19_minitest_mocking_required
      setup_test('Test', 'minitest/unit')
      result = turn 'tmp/test.rb'
      assert result.index('PASS')
    end

    def test_ruby19_minitest_mocking_required_force
      setup_test('Test', 'minitest/unit')
      result = turn '--minitest tmp/test.rb'
      assert result.index('PASS')
    end

    # Ruby 1.9 users must remove ++require 'test/unit'++ from their tests.
    #def test_ruby19_testunit_required
    #  setup_test('Test', 'test/unit')
    #  result = turn 'turn tmp/test.rb'
    #  assert result.index('PASS')
    #end

    # Turn does not support Test::Unit 2.0+.
    #def test_ruby19_testunit_force
    #  setup_test('Test')
    #  result = turn '--testunit tmp/test.rb'
    #  assert result.index('PASS')
    #end

    # Turn does not support Test::Unit 2.0+.
    #def test_ruby19_testunit_required_force
    #  setup_test('Test', 'test/unit')
    #  result = turn '--testunit tmp/test.rb'
    #  assert result.index('PASS')
    #end

  end

else

  class TestRuby18Framework < Test::Unit::TestCase

    def test_ruby18_testunit
      setup_test('Test')
      result = turn 'tmp/test.rb'
      assert result.index('PASS')
    end

    def test_ruby18_testunit_required
      setup_test('Test', 'test/unit')
      result = turn 'tmp/test.rb'
      assert result.index('PASS')
    end

    def test_ruby18_minitest
      setup_test('MiniTest')
      result = turn '--minitest tmp/test.rb'
      assert result.index('PASS')
    end

    def test_ruby18_minitest_mocking_testunit
      setup_test('Test')
      result = turn '--minitest tmp/test.rb'
      assert result.index('PASS')
    end

    # You can't use minitest and have ++require 'test/unit'++ in your tests.
    #def test_ruby18_minitest_mocking_testunit_required
    #  setup_test('Test', 'test/unit')
    #  result = turn '--minitest tmp/test.rb'
    #  assert result.index('PASS')
    #end

    # If you want to use minitest with Ruby 1.8 you have to use force option.
    # TODO: add turn configuration to automatically do this.
    #def test_ruby18_minitest_required
    #  setup_test('MiniTest', 'minitest/unit')
    #  result = turn 'tmp/test.rb'
    #  assert result.index('PASS')
    #end

    def test_ruby18_minitest_required_force
      setup_test('MiniTest', 'minitest/unit')
      result = turn '--minitest tmp/test.rb'
      assert result.index('PASS')
    end

  end

end

