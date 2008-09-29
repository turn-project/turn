#require 'reap/service'

require 'facets' #/hash/reke, string/tabs
require 'facets/progressbar'
require 'facets/dir/multiglob'
require 'fileutils'

require 'turn/colorize'

module Turn

  # Iso Runner provides means from running unit test
  # in isolated processes. It can do this either by running
  # each test in isolation (solo testing) or in pairs (cross testing).
  #
  # The IsoRunner proiveds some variery in ouput formats and can also
  # log results to a file.

  class IsoRunner

    include Turn::Colorize


    # File glob pattern of tests to run.
    attr_accessor :tests

    # Tests to specially exclude.
    attr_accessor :exclude

    # Add these folders to the $LOAD_PATH.
    attr_accessor :loadpath

    # Libs to require when running tests.
    attr_accessor :requires

    # Test against live install (i.e. Don't use loadpath option)
    attr_accessor :live

    # Log results?
    attr_accessor :log

    #
    attr_accessor :trace


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
      end

      # Collect test configuation.

      def test_configuration(options={})
        #options = configure_options(options, 'test')
        #options['loadpath'] ||= metadata.loadpath

        options['tests']    ||= self.tests
        options['loadpath'] ||= self.loadpath
        options['requires'] ||= self.requires
        options['live']     ||= self.live
        options['exclude']  ||= self.exclude

        #options['tests']    = list_option(options['tests'])
        options['loadpath'] = list_option(options['loadpath'])
        options['exclude']  = list_option(options['exclude'])
        options['require']  = list_option(options['require'])

        return options
      end

      def list_option(list)
        case list
        when nil
          []
        when Array
          list
        else
          list.split(/:;/)
        end
      end

      def trace?   ; @trace   ; end
      def verbose? ; @verbose ; end
      #def dryrun?  ; @dryrun  ; end

    public

    # Run unit tests. Unlike test-solo and test-cross this loads
    # all tests and runs them together in a single process.
    #
    # Note that this shells out to the testrb program.
    #
    # TODO: Generate a test log entry?

    def test_run(options={})
      options = test_configuration(options)

      tests    = options['tests']
      loadpath = options['loadpath']
      requires = options['requires']
      live     = options['live']
      exclude  = options['exclude']

      #log      = options['log'] != false
      #logfile  = File.join('log', apply_naming_policy('test', 'log'))

      # what about arguments for selecting specific tests?
      tests = options['arguments'] if options['arguments']

      #unless live
      #  loadpath.each do |lp|
      #    $LOAD_PATH.unshift(File.expand_path(lp))
      #  end
      #end

      if File.exist?('test/suite.rb')
        files = 'test/suite.rb'
      else
        files = Dir.multiglob_r(*tests)
      end

      if files.empty?
        $stderr.puts "No tests."
        return
      end

      filelist = files.select{|file| !File.directory?(file) }.join(' ')

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

    # Load each test independently to ensure there are no
    # require dependency issues. This is actually a bit redundant
    # as test-solo will also cover these results. So we may deprecate
    # this in the future. This does not generate a test log entry.

    def test_load(options={})
      options = test_configuration(options)

      tests    = options['tests']
      loadpath = options['loadpath']
      requires = options['requires']
      live     = options['live']
      exclude  = options['exclude']

      files = Dir.multiglob_r(*tests) - Dir.multiglob_r(*exclude)

      return puts("No tests.") if files.empty?

      max   = files.collect{ |f| f.size }.max
      list  = []

      files.each do |f|
        next unless File.file?(f)
        if r = system("ruby -I#{loadpath.join(':')} #{f} > /dev/null 2>&1")
          puts "%-#{max}s  [PASS]" % [f]  #if verbose?
        else
          puts "%-#{max}s  [FAIL]" % [f]  #if verbose?
          list << f
        end
      end

      puts "  #{list.size} Load Failures"

      if verbose?
        unless list.empty?
          puts "\n-- Load Failures --\n"
          list.each do |f|
            print "* "
            system "ruby -I#{loadpath} #{f} 2>&1"
            #puts
          end
          puts
        end
      end
    end

=begin
    # Run unit-tests. Each test is run in a separate interpretor
    # to prevent script clash. This makes for a more robust test
    # facility and prevents potential conflicts between test scripts.
    #
    #   tests     Test files (eg. test/tc_**/*.rb) [test/**/*]
    #   loadpath  Directories to include in load path [lib].
    #   require   List of files to require prior to running tests.
    #   live      Deactive use of local libs and test against install.

    def test_solo(options={})
      options = test_configuration(options)

      tests    = options['tests']
      loadpath = options['loadpath']
      requires = options['requires']
      live     = options['live']
      exclude  = options['exclude']
      log      = options['log'] != false

      files = Dir.multiglob_r(*tests) - Dir.multiglob_r(*exclude)

      return puts("No tests.") if files.empty?

      files = files.select{ |f| File.extname(f) == '.rb' and File.file?(f) }
      width = files.collect{ |f| f.size }.max

      #project.call(:make) if project.compiles?

      cmd   = %[ruby -I#{loadpath.join(':')} %s]
      dis   = "%-#{width}s"

      testruns = files.collect do |file|
        { 'files'   => file,
          'command' => cmd % file,
          'display' => dis % file
        }
      end

      report = test_loop_runner(testruns)

      puts report

      if log #&& !dryrun?
        #logfile = File.join('log', apply_naming_policy('testlog', 'txt'))
        FileUtils.mkdir_p('log')
        logfile = File.join('log', 'testlog.rdoc')
        File.open(logfile, 'a') do |f|
          f << "= Solo Test @ #{Time.now}\n"
          f << report
          f << "\n"
        end
      end
    end
=end

=begin
    # Run cross comparison testing.
    #
    # This tool runs unit tests in pairs to make sure there is cross
    # library compatibility. Each pari is run in a separate interpretor
    # to prevent script clash. This makes for a more robust test
    # facility and prevents potential conflicts between test scripts.
    #
    #   tests     Test files (eg. test/tc_**/*.rb) [test/**/*]
    #   loadpath  Directories to include in load path.
    #   require   List of files to require prior to running tests.
    #   live      Deactive use of local libs and test against install.

    def test_cross(options={})
      options = test_configuration(options)

      tests    = options['tests']
      loadpath = options['loadpath']
      requires = options['requires']
      live     = options['live']
      exclude  = options['exclude']
      log      = options['log'] != false

      files = Dir.multiglob_r(*tests) - Dir.multiglob_r(exclude)

      return puts("No tests.") if files.empty?

      files = files.select{ |f| File.extname(f) == '.rb' and File.file?(f) }
      width = files.collect{ |f| f.size }.max
      pairs = files.inject([]){ |m, f| files.collect{ |g| m << [f,g] }; m }

      #project.call(:make) if project.compiles?

      cmd   = %[ruby -I#{loadpath.join(':')} -e"load('./%s'); load('%s')"]
      dis   = "%-#{width}s %-#{width}s"

      testruns = pairs.collect do |pair|
        { 'file'    => pair,
          'command' => cmd % pair,
          'display' => dis % pair
        }
      end

      report = test_loop_runner(testruns)

      puts report

      if log #&& !dryrun?
        #logfile = File.join('log', apply_naming_policy('testlog', 'txt'))
        FileUtils.mkdir_p('log')
        logfile = File.join('log', 'testlog.rdoc')
        File.open(logfile, 'a') do |f| 
          f << "= Cross Test @ #{Time.now}\n"
          f << report
          f << "\n"
        end
      end
    end
=end

    private

    # Runs the list of test calls passed to it.
    # This is used by #test_solo and #test_cross.

    def test_loop_runner(testruns)
      width = testruns.collect{ |tr| tr['display'].size }.max

      testruns = if trace?
        test_loop_runner_trace(testruns)
      elsif verbose?
        test_loop_runner_verbose(testruns)
      else
        test_loop_runner_progress(testruns)
      end

      tally = test_tally(testruns)

      report = ""
      report << "\n%-#{width}s       %10s %10s %10s %10s" % [ 'TEST FILE', '  TESTS   ', 'ASSERTIONS', ' FAILURES ', '  ERRORS   ' ]
      report << "\n"

      testruns.each do |testrun|
        count = testrun['count']
        pass = (count[2] == 0 and count[3] == 0)

        report << "%-#{width}s  " % [testrun['display']]
        report << "%10s %10s %10s %10s" % count
        report << " " * 8
        report << (pass ? "[#{PASS}]" : "[#{FAIL}]")
        report << "\n"
      end

      report << "%-#{width}s  " % "TOTAL"
      report << "%10s %10s %10s %10s" % tally

      #puts("\n%i tests, %i assertions, %i failures, %i errors\n\n" % tally)

      report << "\n\n"

      fails = []
      
      fails = testruns.select do |testrun|
        count = testrun['count']
        count[2] != 0 or count[3] != 0
      end

      if tally[2] != 0 or tally[3] != 0
        unless fails.empty? # or verbose?
          report << "-- Failures and Errors --\n\n"
          fails.uniq.each do |testrun|
            report << testrun['result']
          end
          report << "\n"
        end
      end

      return report
    end

    #

    def test_loop_runner_verbose(testruns)
      testruns.each do |testrun|
        result = `#{testrun['command']}`
        count  = test_parse_result(result)
        testrun['count']  = count
        testrun['result'] = result

        puts "\n" * 3; puts result
      end
      puts "\n" * 3

      return testruns
    end

    #

    def test_loop_runner_progress(testruns)
      pbar = Console::ProgressBar.new( 'Testing', testruns.size )
      pbar.inc
      testruns.each do |testrun|
        pbar.inc

        result = `#{testrun['command']}`
        count  = test_parse_result(result)
        testrun['count']  = count
        testrun['result'] = result
      end
      pbar.finish

      return testruns
    end

    #

    def test_loop_runner_trace(testruns)
      width = testruns.collect{ |tr| tr['display'].size }.max

      testruns.each do |testrun|
        print "%-#{width}s  " % [testrun['display']]

        result = `#{testrun['command']}`
        count = test_parse_result(result)
        testrun['count']  = count
        testrun['result'] = result

        pass = (count[2] == 0 and count[3] == 0)
        #puts(pass ? "[PASS]" : "[FAIL]")
        puts(pass ? "[#{PASS}]" : "[#{FAIL}]")
      end

      return testruns
    end

    #

    def test_tally(testruns)
      counts = testruns.collect{ |tr| tr['count'] }
      tally  = [0,0,0,0]
      counts.each do |count|
        4.times{ |i| tally[i] += count[i] }
      end
      return tally
    end

    #

    def test_parse_result(result)
      if md = /(\d+) tests, (\d+) assertions, (\d+) failures, (\d+) errors/.match(result)
        count = md[1..4].collect{|q| q.to_i}
      else       
        count = [1, 0, 0, 1]  # SHOULD NEVER HAPPEN
      end
      return count
    end

  end

end

