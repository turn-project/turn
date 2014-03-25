require File.expand_path(File.dirname(__FILE__)) + '/helper.rb'

class TestRuby19Framework < MiniTest::Unit::TestCase

  def test_ruby19_minitest
    setup_test('MiniTest')
    result = turn 'tmp/test.rb'
    assert result.index('PASS')
  end

  def test_ruby19_minitest_color
    unless defined?(ANSI)
      assert true   # skip ?
      return
    end  

    begin
      term, stdout = ENV['TERM'], $stdout
      host_os, ansicon, = ::RbConfig::CONFIG['host_os'], ENV['ANSICON']
      $stdout = $stdout.dup

      verbose, debug   = $VERBOSE, $DEBUG
      $VERBOSE, $DEBUG = false, false
      def $stdout.tty? ; true ;  end
      $VERBOSE, $DEBUG = verbose, debug

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

      verbose, debug   = $VERBOSE, $DEBUG
      $VERBOSE, $DEBUG = false, false
      def $stdout.tty? ; false ; end
      $VERBOSE, $DEBUG = verbose, debug

      assert_equal false, Turn::Colorize.color_supported?
    ensure
      ENV['TERM'], $stdout = term, stdout
      ::RbConfig::CONFIG['host_os'], ENV['ANSICON'] = host_os, ansicon
    end
  end

  #def test_ruby19_minitest_force
  #  setup_test('MiniTest')
  #  result = turn '--minitest tmp/test.rb'
  #  assert result.index('PASS')
  #end

  def test_ruby19_minitest_required
    setup_test('MiniTest', 'minitest/unit')
    result = turn 'tmp/test.rb'
    assert result.index('PASS')
  end

  #def test_ruby19_minitest_required_force
  #  setup_test('MiniTest', 'minitest/unit')
  #  result = turn '--minitest tmp/test.rb'
  #  assert result.index('PASS')
  #end

  def test_ruby19_minitest_mocking
    setup_test('MiniTest', 'minitest/unit')
    result = turn 'tmp/test.rb'
    assert result.index('PASS'), "RESULT:\n#{result}"
  end

  #def test_ruby19_minitest_mocking_force
  #  setup_test('Test')
  #  result = turn '--minitest tmp/test.rb'
  #  assert result.index('PASS')
  #end

  def test_ruby19_minitest_mocking_required
    setup_test('Test', 'minitest/unit')
    result = turn 'tmp/test.rb'
    assert result.index('PASS')
  end

  #def test_ruby19_minitest_mocking_required_force
  #  setup_test('Test', 'minitest/unit')
  #  result = turn '--minitest tmp/test.rb'
  #  assert result.index('PASS')
  #end

end
