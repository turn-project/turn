#require 'reap/service'

require 'facets' #/hash/reke, string/tabs



  private

    # Runs the list of test calls passed to it.
    # This is used by #test_solo and #test_cross.
    #
    def test_loop_runner(testruns)

      io.start(testruns)

      testruns.each do |testrun|
        io.start_test

        result = `#{testrun.command}`

        counts = test_parse_result(result)

        testrun.counts(*counts)

        if testrun.error?
          io.error
        elsif tetrun.fail?
          io.fail
        else
          io.pass
        end

        testrun.result = result

        io.finish_test
      end

      io.finish

      io.post_report(testruns)
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

