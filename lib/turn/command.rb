require 'getoptlong'

RUBY = File.join(Config::CONFIG['bindir'], Config::CONFIG['ruby_install_name'])

original_argv = ARGV.dup

opts = GetoptLong.new(
  [ '--help', '-h',     GetoptLong::NO_ARGUMENT ],
  [ '--live',           GetoptLong::NO_ARGUMENT ],
  [ '--log',            GetoptLong::NO_ARGUMENT ],
  [ '--loadpath', '-I', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--requires', '-r', GetoptLong::REQUIRED_ARGUMENT ],

  [ '--solo',           GetoptLong::NO_ARGUMENT ],
  [ '--cross',          GetoptLong::NO_ARGUMENT ],
  [ '--load',           GetoptLong::NO_ARGUMENT ]
)

    # Tests to specially exclude.
    #attr_accessor :exclude

mode     = nil
live     = nil
log      = nil
loadpath = ['lib']
requires = []

opts.each do |opt, arg|
  case opt
  when '--help'
    RDoc::usage
    exit 0
  when '--live'
    live = true
  when '--log'
    log = true
  when '--loadpath'
    loadpath = arg
  when '--requires'
    requires = arg
  when '--solo'
    mode = :solo
  when '--cross'
    mode = :cross
  end
end

tests = ARGV

if mode

  case mode
  when :cross
    require 'turn/crossrunner'
    klass = Turn::CrossRunner
  when :solo
    require 'turn/solorunner'
    klass = Turn::SoloRunner
  else
    require 'turn/solorunner'
    klass = Turn::SoloRunner
  end

  testrunner = klass.new do |runner|
    runner.live     = live
    runner.log      = log
    runner.loadpath = loadpath
    runner.requires = requires
    runner.tests    = tests.dup
  end

  testrunner.run_tests

else

  begin
    require 'turn'
    require *ARGV
    #Kernel.exec(RUBY, '-r', 'turn', *ARGV)
  rescue LoadError
    require 'rubygems'
    require 'turn'
    require *ARGV
    #Kernel.exec(RUBY, '-rubygems', '-r', 'turn', *ARGV)
  end

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

# EOF

