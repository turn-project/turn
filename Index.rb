#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/lib/turn/version'

version       Turn::VERSION  #File.read('Version.txt').strip

name         'turn'
title        'Turn'
summary      'Test Reporters (New) -- new output formats for Testing'

description "Turn provides a set of alternative runners for MiniTest, both colorful and informative."

authors [
  'Thomas Sawyer <transfire@gmail.com>',
  'Tim Pease <tim.pease@gmail.com>'
]

requirements [
  'ansi',
  'minitest (test)',
  'rake     (build)',
  'indexer  (build)',
  'mast     (build)'
]

resources(
  'home' => 'http://rubygems.org/gems/turn',
  'code' => 'http://github.com/TwP/turn'
)

copyrights [
  '2006 Tim Pease (MIT)',
  '2009 Thomas Sawyer (MIT)'
]


