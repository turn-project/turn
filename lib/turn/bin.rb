$LOAD_PATH.unshift(File.dirname(File.dirname(__FILE__)))
require 'turn'
#begin
  Turn::Command.main(*ARGV)
#rescue StandardError => e
#  raise if $DEBUG
#  puts e
#  exit -1
#end

