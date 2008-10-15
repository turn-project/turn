require 'fileutils'

module Turn
  require 'turn/components/suite.rb'
  require 'turn/components/case.rb'
  require 'turn/components/method.rb'

  require 'turn/reporters/outline_reporter'
  require 'turn/reporters/marshal_reporter'
  require 'turn/reporters/progress_reporter'

  require 'turn/runners/testrunner'
  require 'turn/runners/solorunner'
  require 'turn/runners/crossrunner'

  class Controller

    # File glob pattern of tests to run.
    # Can be an array of files/globs.
    attr_accessor :tests

    # Files globs to specially exclude.
    attr_accessor :exclude

    # Add these folders to the $LOAD_PATH.
    attr_accessor :loadpath

    # Libs to require when running tests.
    attr_accessor :requires

    # Test against live install (i.e. Don't use loadpath option)
    attr_accessor :live

    # Log results?
    attr_accessor :log

    # Instance of Reporter.
    attr_accessor :reporter

    # Insatance of Runner.
    attr_accessor :runner

    # Verbose output?
    attr_accessor :verbose

    #
    #attr_accessor :trace or :debug?

    def verbose? ; @verbose ; end
    def live?    ; @live    ; end

  private

    def initialize
      yield(self) if block_given?
      initialize_defaults
    end

    #
    def initialize_defaults
      @loadpath ||= ['lib']
      @tests    ||= "test/**/test_*"
      @exclude  ||= []
      @reqiures ||= []
      @live     ||= false
      @log      ||= true
      @reporter ||= OutlineReporter.new($stdout)
      @runner   ||= TestRunner.new
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

    def loadpath=(paths)
      @loadpath = list_option(paths)
    end

    def exclude=(paths)
      @exclude = list_option(paths)
    end

    def requries=(paths)
      @requries = list_option(paths)
    end

    def files
      @files ||= (
        fs = tests.map{ |t| Dir[t] }.flatten #TODO: make descending glob
        fs.select{ |f| !File.directory?(f) }
        ex = exclude.map{ |x| Dir[x] }.flatten #TODO: make descending glob
        fs - ex
      )
    end

    def start
      @files = nil  # reset files just in case

      if files.empty?
        $stderr.puts "No tests."
        return
      end

      testrun = runner.new(self)

      testrun.start
    end

  end

end


=begin
    # Run unit tests. Unlike test-solo and test-cross this loads
    # all tests and runs them together in a single process.
    #
    # Note that this shells out to the testrb program.
    #
    # TODO: Generate a test log entry?
    def test_run(options={})
      #options = test_configuration(options)

      #tests    = options['tests']
      #loadpath = options['loadpath']
      #requires = options['requires']
      #live     = options['live']
      #exclude  = options['exclude']

      #log      = options['log'] != false
      #logfile  = File.join('log', apply_naming_policy('test', 'log'))

      # what about arguments for selecting specific tests?
      #tests = options['arguments'] if options['arguments']

      #unless live
      #  loadpath.each do |lp|
      #    $LOAD_PATH.unshift(File.expand_path(lp))
      #  end
      #end

      #if File.exist?('test/suite.rb')
      #  files = 'test/suite.rb'
      #else
        files = tests.map{ |t| Dir[t] }.flatten #TODO make descending
      #end

      #if files.empty?
      #  $stderr.puts "No tests."
      #  return
      #end

      filelist = files.select{|file| !File.directory?(file) }.join(' ')

      runner.new()

      if live
        command = %[testrb #{filelist} 2>&1]
      else
        command = %[testrb -I#{loadpath.join(':')} #{filelist} 2>&1]
      end

      system command

      #if log && !dryrun?
      #  command = %[testrb -I#{loadpath} #{filelist} > #{logfile} 2>&1]  # /dev/null 2>&1
      #  system command
      #  puts "Updated #{logfile}"
      #end
    end
=end

