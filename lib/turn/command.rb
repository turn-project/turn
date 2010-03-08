# Turn - Pretty Unit Test Runner for Ruby
#
# SYNOPSIS
#   turn [OPTIONS] [RUN MODE] [OUTPUT MODE] [test globs...]
#
# OPTIONS
#   -h --help             display this help information
#      --live             don't use loadpath
#      --log              log results to a file
#   -n --name=PATTERN     only run tests that match regexp PATTERN
#   -I --loadpath=PATHS   add given paths to the $LOAD_PATH
#   -r --requires=PATHS   require given paths before running tests
#
# RUN MODES
#      --normal      run all tests in a single process [default]
#      --solo        run each test in a separate process
#      --cross       run each pair of test files in a separate process
#
# OUTPUT MODES
#   -O --outline     turn's original case/test outline mode [default]
#   -P --progress    indicates progress with progress bar
#   -D --dotted      test/unit's traditonal dot-progress mode
#   -M --marshal     dump output as YAML (normal run mode only)

require 'getoptlong'
require 'turn/controller'

#RUBY = File.join(Config::CONFIG['bindir'], Config::CONFIG['ruby_install_name'])

original_argv = ARGV.dup

opts = GetoptLong.new(
  [ '--help', '-h',     GetoptLong::NO_ARGUMENT ],
  [ '--live',           GetoptLong::NO_ARGUMENT ],
  [ '--log',            GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--name',     '-n', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--loadpath', '-I', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--requires', '-r', GetoptLong::REQUIRED_ARGUMENT ],

  # RUN MODES
  [ '--normal',         GetoptLong::NO_ARGUMENT ],
  [ '--solo',           GetoptLong::NO_ARGUMENT ],
  [ '--cross',          GetoptLong::NO_ARGUMENT ],
  #[ '--load',           GetoptLong::NO_ARGUMENT ],

  # OUTPUT MODES
  [ '--outline',  '-O', GetoptLong::NO_ARGUMENT ],
  [ '--progress', '-P', GetoptLong::NO_ARGUMENT ],
  [ '--dotted',   '-D', GetoptLong::NO_ARGUMENT ],
  [ '--marshal',  '-M', GetoptLong::NO_ARGUMENT ]
)

live     = nil
log      = nil
pattern  = nil
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
  when '--name'
    pattern = Regexp.new(arg, Regexp::IGNORECASE)
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
  when '--dotted'
    outmode = :dotted
  end
end

loadpath = ['lib'] if loadpath.empty?

tests = ARGV.empty? ? nil : ARGV.dup

case outmode
when :marshal
  reporter = Turn::MarshalReporter.new($stdout)
when :progress
  reporter = Turn::ProgressReporter.new($stdout)
when :dotted
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
  c.pattern  = pattern
end

exit controller.start.passed?

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

