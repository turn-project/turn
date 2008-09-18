require 'turn/isorunner'

module Turn

  # Iso Runner provides means from running unit test
  # in isolated processes. It can do this either by running
  # each test in isolation (solo testing) or in pairs (cross testing).
  #
  # The IsoRunner proives some variery in ouput formats and can also
  # log results to a file.
  #
  class CrossRunner < IsoRunner

    #include Turn::Colorize

    # File glob pattern of tests to run.
    attr_accessor :tests

    # File glob pattern of tests to cross run.
    attr_accessor :versus

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

      #
      def initialize_defaults
        @loadpath ||= ['lib']
        @tests    ||= "test/**/test_*"
        @versus   ||= "test/**/test_*"
        @exclude  ||= []
        @reqiures ||= []
        @live     ||= false
        @log      ||= false
      end

      # Collect test configuation.

      def test_configuration(options={})
        options['tests']    ||= self.tests
        options['versus']   ||= self.versus
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

    # Run cross comparison testing.
    #
    # This tool runs unit tests in pairs to make sure there is cross
    # library compatibility. Each pari is run in a separate interpretor
    # to prevent script clash. This makes for a more robust test
    # facility and prevents potential conflicts between test scripts.
    #
    #   tests     Test files (eg. test/tc_**/*.rb) [test/**/*]
    #   versus    Vs. test files (eg. test/tc_**/*.rb) [test/**/*]
    #   loadpath  Directories to include in load path.
    #   require   List of files to require prior to running tests.
    #   live      Deactive use of local libs and test against install.

    def run_tests(options={})
      options = test_configuration(options)

      tests    = options['tests']
      versus   = options['versus']
      loadpath = options['loadpath']
      requires = options['requires']
      live     = options['live']
      exclude  = options['exclude']
      log      = options['log'] != false

      files = Dir.multiglob_r(*tests) - Dir.multiglob_r(exclude)
      viles = Dir.multiglob_r(*versus) - Dir.multiglob_r(exclude)

      return puts("No tests.") if files.empty?

      files = files.select{ |f| File.extname(f) == '.rb' and File.file?(f) }
      viles = viles.select{ |f| File.extname(f) == '.rb' and File.file?(f) }

      width = (files+viles).collect{ |f| f.size }.max

      pairs = files.inject([]){ |m, f| viles.collect{ |g| m << [f,g] }; m }

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
        logfile = File.join('log', 'testlog.txt')
        File.open(logfile, 'a') do |f| 
          f << "= Cross Test @ #{Time.now}\n"
          f << report
          f << "\n"
        end
      end
    end

  end

end

