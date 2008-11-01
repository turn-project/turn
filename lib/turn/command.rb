# Turn - Pretty Unit Test Runner for Ruby
#
# SYNOPSIS
#   turn [OPTIONS] [RUN MODE] [OUTPUT MODE] [test globs...]
#
# OPTIONS
#   -h --help
#      --live
#      --log
#   -I --loadpath=PATHS
#   -r --requires=PATHS
#
# RUN MODES
#      --solo
#      --cross
#
# OUTPUT MODES
#   -O --outline
#   -P --progress
#   -M --marshal

require 'getoptlong'
require 'turn/controller'

#RUBY = File.join(Config::CONFIG['bindir'], Config::CONFIG['ruby_install_name'])

original_argv = ARGV.dup

opts = GetoptLong.new(
  [ '--help', '-h',     GetoptLong::NO_ARGUMENT ],
  [ '--live',           GetoptLong::NO_ARGUMENT ],
  [ '--log',            GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--loadpath', '-I', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--requires', '-r', GetoptLong::REQUIRED_ARGUMENT ],

  # RUN MODES
  [ '--solo',           GetoptLong::NO_ARGUMENT ],
  [ '--cross',          GetoptLong::NO_ARGUMENT ],
  #[ '--load',           GetoptLong::NO_ARGUMENT ],

  # OUTPUT MODES
  [ '--outline',  '-O', GetoptLong::NO_ARGUMENT ],
  [ '--progress', '-P', GetoptLong::NO_ARGUMENT ],
  [ '--nominal',  '-N', GetoptLong::NO_ARGUMENT ],
  [ '--marshal',  '-M', GetoptLong::NO_ARGUMENT ]
)

live     = nil
log      = nil
loadpath = []
requires = []

runmode = nil
outmode = nil

opts.each do |opt, arg|
  case opt
  when '--help'
    help, rest = File.read(__FILE__).split(/^\s*$/)
    puts help.gsub(/^\#[ ]{0,1}/,'')
    exit

  when '--live'
    live = true
  when '--log'
    log = true
  when '--loadpath'
    loadpath << arg
  when '--requires'
    requires << arg

  when '--solo'
    runmode = :solo
  when '--cross'
    runmode = :cross
  when '--marshal'
    runmode = :marshal
    outmode = :marshal
  when '--progress'
    outmode = :progress
  when '--outline'
    outmode = :outline
  when '--nominal'
    outmode = :nominal
  end
end

loadpath = ['lib'] if loadpath.empty?

tests = ARGV.empty? ? nil : ARGV.dup

case outmode
when :marshal
  reporter = Turn::MarshalReporter.new($stdout)
when :progress
  reporter = Turn::ProgressReporter.new($stdout)
when :nominal
  reporter = Turn::DotReporter.new($stdout)
else
  reporter = Turn::OutlineReporter.new($stdout)
end

case runmode
when :marshal
  require 'turn/runners/testrunner'
  runner   = Turn::TestRunner
when :solo
  require 'turn/runners/solorunner'
  runner = Turn::SoloRunner
when :cross
  require 'turn/runners/crossrunner'
  runner = Turn::CrossRunner
else
  require 'turn/runners/testrunner'
  runner = Turn::TestRunner
end

controller = Turn::Controller.new do |c|
  c.live     = live
  c.log      = log
  c.loadpath = loadpath
  c.requires = requires
  c.tests    = tests
  c.runner   = runner
  c.reporter = reporter
end

controller.start

=begin
else

  begin
    require 'turn/adapters/testunit' # 'turn'
  rescue LoadError
    require 'rubygems'
    require 'turn/adapters/testunit' # 'turn'
  end

  ARGV.each{ |a| Dir[a].each{ |f| require f }}
  Turn::TestRunner.run(TS_MyTests)

  #RUBY = File.join(Config::CONFIG['bindir'], Config::CONFIG['ruby_install_name'])
  #
  #begin
  #  require 'turn'
  #  Kernel.exec(RUBY, '-r', 'turn', *ARGV)
  #rescue LoadError
  #  require 'rubygems'
  #  require 'turn'
  #  Kernel.exec(RUBY, '-rubygems', '-r', 'turn', *ARGV)
  #end

end
=end

