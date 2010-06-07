$LOAD_PATH.unshift(File.dirname(File.dirname(__FILE__)))
require 'turn/command'
Turn::Command.main(*ARGV)

