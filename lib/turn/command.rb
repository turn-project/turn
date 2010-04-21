require 'optparse'
require 'turn/controller'

module Turn

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
  #   -I --loadpath=PATHS   add given PATHS to the $LOAD_PATH
  #   -r --requires=LIBS    require given LIBS before running tests
  #   -m --minitest         Force use of MiniTest framework.
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
  #
  class Command

    # Shortcut for new.main(*argv)
    def self.main(*argv)
      new.main(*argv)
    end


    # Log output.
    attr :log

    # Do not use local loadpath.
    attr :live

    # Only run tests matching this pattern.
    attr :pattern

    # List of paths to add to $LOAD_PATH
    attr :loadpath

    # Libraries to require before running tests.
    attr :requires

    # Framework to use, :minitest or :testunit.
    attr :framework

    # Run mode.
    attr :runmode

    # Output mode.
    attr :outmode

    #
    def initialize
      @live      = nil
      @log       = nil
      @pattern   = nil
      @loadpath  = []
      @requires  = []
      @runmode   = nil
      @outmode   = nil
      @framework = RUBY_VERSION >= "1.9" ? :minitest : :testunit
    end

    #
    def option_parser
      OptionParser.new do |opts|

        opts.banner = "  # Turn - Pretty Unit Test Runner for Ruby"

        opts.separator " "
        opts.separator "SYNOPSIS"
        opts.separator "  turn [OPTIONS] [RUN MODE] [OUTPUT MODE] [TEST GLOBS ...]"

        opts.separator " "
        opts.separator "GENERAL OPTIONS"

        opts.on('-I', '--loadpath=PATHS', "add paths to $LOAD_PATH") do |path|
          @loadpath << path
        end

        opts.on('-r', '--require=LIBS', "require libraries") do |lib|
          @requires << lib
        end

        opts.on('-n', '--name=PATTERN', "only run tests that match PATTERN") do |pattern|
          @pattern = Regexp.new(pattern, Regexp::IGNORECASE)
        end

        opts.on('-m', '--minitest', "Force use of MiniTest framework") do
          @framework = :minitest
        end

        opts.on('--log', "log results to a file") do #|path|
          @log = true # TODO: support path/file
        end

        opts.on('--live', "do not use local load path") do
          @live = true
        end

        opts.separator " "
        opts.separator "RUN MODES"

        opts.on('--normal', "run all tests in a single process [default]") do
          @runmode = nil
        end

        opts.on('--solo', "run each test in a separate process") do
          @runmode = :solo
        end

        opts.on('--cross', "run each pair of test files in a separate process") do
          @runmode = :cross
        end

        #opts.on('--load', "") do
        #end

        opts.separator " "
        opts.separator "OUTPUT MODES"

        opts.on('--outline', '-O', "turn's original case/test outline mode [default]") do
          @outmode = :outline
        end

        opts.on('--progress', '-P', "indicates progress with progress bar") do
          @outmode = :progress
        end

        opts.on('--dotted', '-D', "test/unit's traditonal dot-progress mode") do
          @outmode = :dotted
        end

        opts.on('--marshal', '-M', "dump output as YAML (normal run mode only)") do
          @runmode = :marshal
          @outmode = :marshal
        end

        opts.separator " "
        opts.separator "COMMAND OPTIONS"

        opts.on_tail('--help', '-h', "display this help information") do
          puts opts
          exit
        end
      end
    end

    # Run command.
    def main(*argv)
      option_parser.parse!(argv)

      @loadpath = ['lib'] if loadpath.empty?

      tests = ARGV.empty? ? nil : ARGV.dup

      controller = Turn::Controller.new do |c|
        c.live      = live
        c.log       = log
        c.loadpath  = loadpath
        c.requires  = requires
        c.tests     = tests
        c.runner    = runner
        c.reporter  = reporter
        c.pattern   = pattern
        c.framework = framework
      end

      result = controller.start

      exit result.passed?
    end

    # Select reporter based on output mode.
    def reporter
      case outmode
      when :marshal
        Turn::MarshalReporter.new($stdout)
      when :progress
        Turn::ProgressReporter.new($stdout)
      when :dotted
        Turn::DotReporter.new($stdout)
      else
        Turn::OutlineReporter.new($stdout)
      end
    end

    # Select runner based on run mode.
    def runner
      if framework == :minitest
        require 'turn/runners/minirunner'
      else
        require 'turn/runners/testrunner'
      end

      case runmode
      when :marshal
        if framework == :minitest
          Turn::MiniRunner
        else
          Turn::TestRunner
        end
      when :solo
        require 'turn/runners/solorunner'
        Turn::SoloRunner
      when :cross
        require 'turn/runners/crossrunner'
        Turn::CrossRunner
      else
        if framework == :minitest
          Turn::MiniRunner
        else
          Turn::TestRunner
        end
      end
    end

  end

end
