require File.expand_path(File.dirname(__FILE__)) + '/helper.rb'

# Test on Ruby 1.9+
if RUBY_VERSION >= '1.9'

  class TestRuby19Framework < MiniTest::Unit::TestCase

    def test_ruby19_minitest
      setup_test('MiniTest')
      result = turn 'tmp/test.rb'
      assert result.index('PASS')
    end

    def test_ruby19_minitest_color
      term, stdout = ENV['TERM'], $stdout
      host_os, ansicon, = ::RbConfig::CONFIG['host_os'], ENV['ANSICON']
      $stdout = $stdout.dup
      def $stdout.tty?
        true
      end
      ENV['ANSICON'] = nil
      ENV['TERM'] = 'xterm'
      assert_equal true, Turn::Colorize.color_supported?
      ENV['TERM'] = 'dumb'
      assert_equal false, Turn::Colorize.color_supported?
      ENV['TERM'] = nil
      assert_equal false, Turn::Colorize.color_supported?
      ['mingw32', 'mswin32'].each do |os|
        ::RbConfig::CONFIG['host_os'] = os
        ENV['ANSICON'] = '120x5000 (120x50)'
        assert_equal true, Turn::Colorize.color_supported?
        ENV['ANSICON'] = nil
        assert_equal false, Turn::Colorize.color_supported?
      end
      ENV['TERM'] = 'xterm'
      def $stdout.tty?
        false
      end
      assert_equal false, Turn::Colorize.color_supported?
    ensure
      ENV['TERM'], $stdout = term, stdout
      ::RbConfig::CONFIG['host_os'], ENV['ANSICON'] = host_os, ansicon
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

