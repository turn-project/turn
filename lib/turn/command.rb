require 'optparse'

module Turn
  require 'turn/controller'

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
  #   -t --trace            Turn on invoke/execute tracing, enable full backtrace.
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
  #      --pretty      new pretty reporter
  #   -M --marshal     dump output as YAML (normal run mode only)
  #   -Q --queued      interactive testing
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

    # Framework to use, :minitest or :testunit.
    attr :framework

    # Run mode.
    attr :runmode

    # Output mode.
    attr :outmode

    # Enable full backtrace
    attr :trace

    # Selecting trace type (Rails)
    attr :tracetype

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
      @framework = RUBY_VERSION >= "1.9" ? :minitest : :testunit
      @trace     = nil
      @tracetype = nil
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

        opts.on('-t', '--testcase=PATTERN', "only run testcases that match PATTERN") do |pattern|
          if pattern =~ /\/(.*)\//
            @matchcase = Regexp.new($1)
          else
            @matchcase = Regexp.new(pattern, Regexp::IGNORECASE)
          end
        end

        opts.on('-m', '--minitest', "Force use of MiniTest framework") do
          @framework = :minitest
        end

        opts.on("-t", '--trace', "Turn on invoke/execute tracing, enable full backtrace") do
          @trace = true
        end

        opts.on('--tracetype=TYPE', 'for RAILS - select "application" backtrace (default),
                                     "framework" backtrace or "full" backtrace') do |type|
          @tracetype = type
        end

        # Turn does not support Test::Unit 2.0+
        #opts.on('-u', '--testunit', "Force use of TestUnit framework") do
        #  @framework = :testunit
        #end

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

        opts.on('--dotted', '-D', "test-unit's traditonal dot-progress mode") do
          @outmode = :dotted
        end

        opts.on('--pretty', '-T', "new pretty output mode") do
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
        opts.separator "COMMAND OPTIONS"

        opts.on('--debug', "turn debug mode on") do
          $VERBOSE = true
          $DEBUG   = true
        end

        opts.on_tail('--version', "display version") do
          puts VERSION
          exit
        end

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
        c.runmode   = runmode
        c.format    = outmode
        c.pattern   = pattern
        c.matchcase = matchcase
        c.framework = framework
        c.trace     = trace
        c.tracetype = tracetype
      end

      result = controller.start

      if result
        exit result.passed?
      else # no tests
        exit
      end
    end

  end

end
