#require 'reap/service'

#require 'facets' #/hash/reke, string/tabs
#require 'facets/progressbar'
#require 'facets/dir/multiglob'
#require 'fileutils'

module Turn
  require 'turn/colorize'

  # Iso Runner provides means from running unit test
  # in isolated processes. It can do this either by running
  # each test in isolation (solo testing) or in pairs (cross testing).
  #
  # The IsoRunner proiveds some variery in ouput formats and can also
  # log results to a file.

  class IsoRunner
    include Turn::Colorize

    attr :reporter

  private

    def initialize(controller)
      @controller = controller
      @reporter = controller.reporter
      #yield(self) if block_given?
    end

  public

    # Runs the list of test calls passed to it.
    # This is used by #test_solo and #test_cross.
    #
    def start
      suite = TestSuite.new
      testruns = @controller.files.collect do |file|
        suite.new_case(file)
      end
      test_loop_runner(suite)
    end

  private

    #
    def test_loop_runner(suite)
      reporter.start_suite(suite)
      suite.each_with_index do |kase, index|
        reporter.start_case(kase)

        # FRACKING GENIUS RIGHT HERE !!!!!!!!!!!!
        result = `turn --marshal #{kase.files.join(' ')}` #TODO: Add the other controller options.
        head, yaml = *result.split('---')
        sub_suite = YAML.load(yaml)
        kase = sub_suite.cases[0]
        suite.cases[index] = kase

        kase.tests.each do |test|
          reporter.start_test(test)

          if test.error?
            reporter.error(test.message)
          elsif test.fail?
            reporter.fail(test.message)
          else
            reporter.pass
          end

          reporter.finish_test(test)
        end

        #kase.message = result
        reporter.finish_case(kase)
      end
      reporter.finish_suite(suite)
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

    #
    def log_report(report)
      if log #&& !dryrun?
        #logfile = File.join('log', apply_naming_policy('testlog', 'txt'))
        FileUtils.mkdir_p('log')
        logfile = File.join('log', 'testlog.txt')
        File.open(logfile, 'a') do |f|
          f << "= Solo Test @ #{Time.now}\n"
          f << report
          f << "\n"
        end
      end
    end

  end #IsoRunner

end #module Turn





=begin

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
=end






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

=begin
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
=end

