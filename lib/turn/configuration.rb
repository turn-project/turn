module Turn

  # Configure Turn
  def self.config(&block)
    @config ||= Configuration.new
    block.call(@config) if block
    @config
  end

  # TODO: Support for test run loggging ?

  # Central interface for Turn configuration.
  #
  class Configuration

    # List of if file names or glob pattern of tests to run.
    attr_reader :tests

    # List of file names or globs to exclude from +tests+ list.
    attr_reader :exclude

    # Regexp pattern that all test name's must
    # match to be eligible to run.
    attr_accessor :pattern

    # Regexp pattern that all test cases must
    # match to be eligible to run.
    attr_accessor :matchcase

    # Add these folders to the $LOAD_PATH.
    attr_reader :loadpath

    # Libs to require when running tests.
    attr_reader :requires

    # Reporter type.
    attr_accessor :format

    # Run mode.
    attr_accessor :runmode

    # Test against live install (i.e. Don't use loadpath option)
    attr_accessor :live

    # Log results? May be true/false or log file name. (TODO)
    attr_accessor :log

    # Verbose output?
    attr_accessor :verbose

    # Test framework, either :minitest or :testunit
    attr_accessor :framework

    # Enable full backtrace
    attr_accessor :trace

    # Use natural language case names.
    attr_accessor :natural

    def verbose? ; @verbose ; end
    def live?    ; @live    ; end
    def natural? ; @natural ; end
    def ansi?    ; @ansi    ; end

  private

    def initialize
      yield(self) if block_given?
      initialize_defaults
    end

    #
    def initialize_defaults
      @loadpath  ||= ['lib']
      @tests     ||= ["test/**/{test,}*{,test}.rb"]
      @exclude   ||= []
      @requires  ||= []
      @live      ||= false
      @log       ||= true
      #@format   ||= nil
      #@runner   ||= RUBY_VERSION >= "1.9" ? MiniRunner : TestRunner
      @matchcase ||= nil
      @pattern   ||= /.*/
      @natural   ||= false
      @trace     ||= environment_trace
      @ansi      ||= nil

      @files = nil  # reset files just in case
    end

    # Collect test configuation.
    #def test_configuration(options={})
    #  #options = configure_options(options, 'test')
    #  #options['loadpath'] ||= metadata.loadpath
    #  options['tests']    ||= self.tests
    #  options['loadpath'] ||= self.loadpath
    #  options['requires'] ||= self.requires
    #  options['live']     ||= self.live
    #  options['exclude']  ||= self.exclude
    #  #options['tests']    = list_option(options['tests'])
    #  options['loadpath'] = list_option(options['loadpath'])
    #  options['exclude']  = list_option(options['exclude'])
    #  options['require']  = list_option(options['require'])
    #  return options
    #end

    #
    def list_option(list)
      case list
      when nil
        []
      when Array
        list
      else
        list.split(/[:;]/)
      end
    end

  public

    def ansi=(boolean)
      @ansi = boolean ? true : false
    end

    def tests=(paths)
      @tests = list_option(paths)
    end

    def loadpath=(paths)
      @loadpath = list_option(paths)
    end

    def exclude=(paths)
      @exclude = list_option(paths)
    end

    def requires=(paths)
      @requires = list_option(paths)
    end

    # Test files.
    def files
      @files ||= (
        fs = tests.map do |t|
          File.directory?(t) ? Dir[File.join(t, '**', '*')] : Dir[t]
        end
        fs = fs.flatten.reject{ |f| File.directory?(f) }

        ex = exclude.map do |x|
          File.directory?(x) ? Dir[File.join(x, '**', '*')] : Dir[x]
        end
        ex = ex.flatten.reject{ |f| File.directory?(f) }

        (fs - ex).uniq.map{ |f| File.expand_path(f) }
      ).flatten
    end

    # TODO: Better name ?
    def suite_name
      files.map{ |path| File.dirname(path).sub(Dir.pwd+'/','') }.uniq.join(',')
    end

    # Select reporter based on output mode.
    def reporter
      @reporter ||= (
        opts = { :trace=>trace, :natural=>natural? }
        case format
        when :marshal
          require 'turn/reporters/marshal_reporter'
          Turn::MarshalReporter.new($stdout, opts)
        when :progress
          require 'turn/reporters/progress_reporter'
          Turn::ProgressReporter.new($stdout, opts)
        when :dotted, :dot
          require 'turn/reporters/dot_reporter'
          Turn::DotReporter.new($stdout, opts)
        when :pretty
          require 'turn/reporters/pretty_reporter'
          Turn::PrettyReporter.new($stdout, opts)
        when :cue
          require 'turn/reporters/cue_reporter'
          Turn::CueReporter.new($stdout, opts)
        else
          require 'turn/reporters/outline_reporter'
          Turn::OutlineReporter.new($stdout, opts)
        end
      )
    end

    #
    def environment_trace
      (ENV['backtrace'] ? ENV['backtrace'].to_i : nil)
    end

  end

end
