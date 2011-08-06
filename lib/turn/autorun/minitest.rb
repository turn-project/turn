require 'minitest/unit'
require 'minitest/spec'
#require 'rubygems'
require 'turn/colorize'
require 'turn/controller'
require 'turn/runners/minirunner'

MiniTest::Unit.runner = Turn::MiniRunner.new
