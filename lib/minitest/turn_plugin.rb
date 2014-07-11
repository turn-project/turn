module Minitest

  # Select report format.
  #
  #     -T outline                turn's original case/test outline mode
  #     -T progress               indicates progress with progress bar
  #     -T dot                    test-unit's traditonal dot-progress mode
  #     -T pretty                 new pretty output mode [default]
  #     -T cue                    cue for action on each failure/error
  #     -T marshal                dump output as YAML (normal run mode only)
  #
  def self.plugin_turn_options(opts, options)
    options[:loadpath] ||= []
    options[:requires] ||= []

    # TODO: Really want a way not to do all the other options unless `-t`.
    unless $turn_command
      opts.on "-t", "--turn", "Use Turn for output." do |format|
        $turn_command = true
      end
    end

    opts.separator " "
    opts.separator "turn options:"

    if $turn_command
      opts.on('-I', '--loadpath=PATHS', "add paths to $LOAD_PATH") do |path|
        options[:loadpath].concat(path.split(':'))
      end

      opts.on('-r', '--require=LIBS', "require libraries") do |lib|
        options[:requires].concat(lib.split(':'))
      end
    end

    # TODO: DEPRECATED b/c this is supported by minitest itself now
    #opts.on('-n', '--name=PATTERN', "only run tests that match PATTERN") do |pattern|
    #  if pattern =~ /\/(.*)\//
    #    options[:pattern] = Regexp.new($1)
    #  else
    #    options[:pattern] = Regexp.new(pattern, Regexp::IGNORECASE)
    #  end
    #end
    # TODO: minitest should support this too, it would require a monkey patch by us
    #opts.on('-c', '--case=PATTERN', "only run test cases that match PATTERN") do |pattern|
    #  if pattern =~ /\/(.*)\//
    #    options[:matchcase] = Regexp.new($1)
    #  else
    #    options[:matchcase] = Regexp.new(pattern, Regexp::IGNORECASE)
    #  end
    #end
    opts.on('-m', '--mark=SECONDS', "Mark test if it exceeds runtime threshold.") do |int|
      options[:mark] = int.to_i
    end

    # TODO: rename this and make the count selectable
    opts.on('--topten', "show only top ten slowest tests") do
      options[:decmode] = :topten
    end

    opts.on('--natural', "Show natualized test names.") do |bool|
      options[:natural] = bool
    end
    opts.on('-v', '--verbose', "Show extra information.") do |bool|
      options[:verbose] = bool
    end
    opts.on('-b', '--backtrace', '--trace INT', "Limit the number of lines of backtrace.") do |int|
      options[:trace] = int
    end
    opts.on('--[no-]ansi', "Force use of ANSI codes on or off.") do |bool|
      options[:ansi] = bool
    end
    opts.on('--log', "log results to a file") do #|path|
      options[:log] = true # TODO: support path/file
    end
    opts.on('--live', "do not use local load path") do
      options[:live] = true
    end

    opts.on('--normal', "run all tests in a single process [default]") do
      options[:runmode] = nil
    end
    opts.on('--solo', "run each test in a separate process") do
      options[:runmode] = :solo
    end
    opts.on('--cross', "run each pair of test files in a separate process") do
      options[:runmode] = :cross
    end

    # TODO: reduce these to a single option
    opts.on('--outline', '-O', "turn's original case/test outline mode") do
      options[:outmode] = :outline
    end
    opts.on('--progress', '-P', "indicates progress with progress bar") do
      options[:outmode] = :progress
    end
    opts.on('--dot', '--dotted', '-D', "test-unit's traditonal dot-progress mode") do
      options[:outmode] = :dot
    end
    opts.on('--pretty', '-R', '-T', "new pretty output mode [default]") do
      options[:outmode] = :pretty
    end
    opts.on('--cue', '-C', "cue for action on each failure/error") do
      options[:outmode] = :cue
    end
    opts.on('--marshal', '-M', "dump output as YAML (normal run mode only)") do
      options[:runmode] = :marshal
      options[:outmode] = :marshal
    end

    opts.on('--debug', "turn debug mode on") do
      $DEBUG = true
    end
    opts.on('--warn', "turn warnings on") do
      $VERBOSE = true
    end

    # DEPRECATED Thanks to minitest-reporter-api gem.
    #unless options[:minitap]
    #  if defined?(Minitest::TapY) && self.reporter == Minitest::TapY
    #    options[:minitap] = 'tapy'
    #  elsif defined?(Minitest::TapJ) && self.reporter == Minitest::TapJ
    #    options[:minitap] = 'tapj'
    #  end
    #end
  end

  #
  #
  def self.plugin_turn_init(options)
    if $turn_command || ENV['turn']

      require 'turn'

      self.reporter.reporters.clear

      format = options[:outmode] || ENV['turn'] || 'pretty'

      case format.to_s
      when 'dot', 'd'
        require 'turn/reporters/dot_reporter'
        self.reporter << Turn::DotReporter.new(options)
      when 'cue', 'c'
        require 'turn/reporters/cue_reporter'
        self.reporter << Turn::CueReporter.new(options)
      when 'pretty', 't'
        require 'turn/reporters/pretty_reporter'
        self.reporter << Turn::PrettyReporter.new(options)
      when 'outline', 'o'
        require 'turn/reporters/outline_reporter'
        self.reporter << Turn::OutlineReporter.new(options)
      when 'progress', 'p'
        require 'turn/reporters/progress_reporter'
        self.reporter << Turn::ProgressReporter.new(options)
      when 'marshal', 'm'
        require 'turn/reporters/marshal_reporter'
        self.reporter << Turn::MarshalReporter.new(options)
      else
        raise "Unknown reporter -- `#{format}'"
      end

      options[:tests] = ARGV.empty? ? nil : ARGV.dup

      config = Turn.config
      config.tests     = options[:tests]
      config.live      = options[:live]
      config.log       = options[:log]
      config.loadpath  = options[:loadpath]
      config.requires  = options[:requires]
      config.runmode   = options[:runmode]
      config.format    = options[:outmode]
      config.mode      = options[:decmode]
      config.pattern   = options[:pattern]
      config.matchcase = options[:matchcase]
      config.trace     = options[:trace]
      config.natural   = options[:natural]
      config.verbose   = options[:verbose]
      config.mark      = options[:mark]
      config.ansi      = options[:ansi] unless options[:ansi].nil?

      config.loadpath.each{ |path| $: << path } unless config.live?
      config.requires.each{ |path| require(path) }

      # load'em up
      if $turn_command
        config.files.each{ |path| require(path) }
      end
    end
  end

end

