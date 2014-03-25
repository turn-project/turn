require 'optparse'

module Turn

  # Turn - Pretty Unit Test Runner for Ruby
  #  
  # SYNOPSIS
  #   turn [OPTIONS] [RUN MODE] [OUTPUT MODE] [TEST GLOBS ...]
  #  
  # GENERAL OPTIONS
  #     -I, --loadpath=PATHS             add paths to $LOAD_PATH
  #     -r, --require=LIBS               require libraries
  #     -n, --name=PATTERN               only run tests that match PATTERN
  #     -c, --case=PATTERN               only run test cases that match PATTERN
  #     -b, --backtrace, --trace INT     Limit the number of lines of backtrace.
  #         --natural                    Show natualized test names.
  #         --[no-]ansi                  Force use of ANSI codes on or off.
  #         --log                        log results to a file
  #         --live                       do not use local load path
  #  
  # RUN MODES
  #         --normal                     run all tests in a single process [default]
  #         --solo                       run each test in a separate process
  #         --cross                      run each pair of test files in a separate process
  #  
  # OUTPUT MODES
  #     -O, --outline                    turn's original case/test outline mode
  #     -P, --progress                   indicates progress with progress bar
  #     -D, --dot, --dotted              test-unit's traditonal dot-progress mode
  #     -R, -T, --pretty                 new pretty output mode [default]
  #     -C, --cue                        cue for action on each failure/error
  #     -M, --marshal                    dump output as YAML (normal run mode only)
  #  
  # COMMAND OPTIONS
  #         --debug                      turn debug mode on
  #         --version                    display version
  #     -h, --help                       display this help information
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

    # Only run testcases matching this pattern.
    attr :matchcase

    # List of paths to add to $LOAD_PATH
    attr :loadpath

    # Libraries to require before running tests.
    attr :requires

    # Run mode.
    attr :runmode

    # Output mode.
    attr :outmode

    # Decorator mode.
    attr :decmode

    # Enable full backtrace
    attr :trace

    # Use natural test case names.
    attr :natural

    # Show extra information.
    attr :verbose

    # Show extra information.
    attr :mark

    # Force ANSI use on or off.
    attr :ansi

    #
    def initialize
      @live      = nil
      @log       = nil
      @pattern   = nil
      @matchcase = nil
      @loadpath  = []
      @requires  = []
      @runmode   = nil
      @outmode   = nil
      @decmode   = nil
      @trace     = nil
      @natural   = false
      @verbose   = false
      @mark      = nil
      @ansi      = nil
    end

    #
    def option_parser
      OptionParser.new do |opts|

        opts.banner = "Turn - Pretty Unit Test Runner for Ruby"

        opts.separator " "
        opts.separator "SYNOPSIS"
        opts.separator "  turn [OPTIONS] [RUN MODE] [OUTPUT MODE] [TEST GLOBS ...]"

        opts.separator " "
        opts.separator "GENERAL OPTIONS"

        opts.on('-I', '--loadpath=PATHS', "add paths to $LOAD_PATH") do |path|
          @loadpath.concat(path.split(':'))
        end

        opts.on('-r', '--require=LIBS', "require libraries") do |lib|
          @requires.concat(lib.split(':'))
        end

        opts.on('-n', '--name=PATTERN', "only run tests that match PATTERN") do |pattern|
          if pattern =~ /\/(.*)\//
            @pattern = Regexp.new($1)
          else
            @pattern = Regexp.new(pattern, Regexp::IGNORECASE)
          end
        end

        opts.on('-c', '--case=PATTERN', "only run test cases that match PATTERN") do |pattern|
          if pattern =~ /\/(.*)\//
            @matchcase = Regexp.new($1)
          else
            @matchcase = Regexp.new(pattern, Regexp::IGNORECASE)
          end
        end

        opts.on('-m', '--mark=SECONDS', "Mark test if it exceeds runtime threshold.") do |int|
          @mark = int.to_i
        end

        opts.on('-b', '--backtrace', '--trace INT', "Limit the number of lines of backtrace.") do |int|
          @trace = int
        end

        opts.on('--natural', "Show natualized test names.") do |bool|
          @natural = bool
        end

        opts.on('-v', '--verbose', "Show extra information.") do |bool|
          @verbose = bool
        end

        opts.on('--[no-]ansi', "Force use of ANSI codes on or off.") do |bool|
          @ansi = bool
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

        opts.on('--outline', '-O', "turn's original case/test outline mode") do
          @outmode = :outline
        end

        opts.on('--progress', '-P', "indicates progress with progress bar") do
          @outmode = :progress
        end

        opts.on('--dot', '--dotted', '-D', "test-unit's traditonal dot-progress mode") do
          @outmode = :dot
        end

        opts.on('--pretty', '-R', '-T', "new pretty output mode [default]") do
          @outmode = :pretty
        end

        opts.on('--cue', '-C', "cue for action on each failure/error") do
          @outmode = :cue
        end

        opts.on('--marshal', '-M', "dump output as YAML (normal run mode only)") do
          @runmode = :marshal
          @outmode = :marshal
        end

        opts.separator " "
        opts.separator "DECORATOR MODES"

        opts.on('--topten', "show only top ten slowest tests") do
          @decmode = :topten
        end

        opts.separator " "
        opts.separator "COMMAND OPTIONS"

        opts.on('--debug', "turn debug mode on") do
          $DEBUG = true
        end

        opts.on('--warn', "turn warnings on") do
          $VERBOSE = true
        end

        opts.on_tail('--version', "display version") do
          puts VERSION
          exit
        end

        opts.on_tail('-h', '--help', "display this help information") do
          puts opts
          exit
        end
      end
    end

    # Run command.
    def main(*argv)
      option_parser.parse!(argv)

      @loadpath = ['lib'] if loadpath.empty?

      tests = ARGV.empty? ? nil : argv.dup

      #config = Turn::Configuration.new do |c|
      config = Turn.config do |c|
        c.live      = live
        c.log       = log
        c.loadpath  = loadpath
        c.requires  = requires
        c.tests     = tests
        c.runmode   = runmode
        c.format    = outmode
        c.mode      = decmode
        c.pattern   = pattern
        c.matchcase = matchcase
        c.trace     = trace
        c.natural   = natural
        c.verbose   = verbose
        c.mark      = mark
        c.ansi      = ansi unless ansi.nil?
      end

      controller = Turn::Controller.new(config)

      result = controller.start

      if result
        exit (result.passed? ? 0 : -1)
      else # no tests
        exit -1
      end
    end

  end

end
