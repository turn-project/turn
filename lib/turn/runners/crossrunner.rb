module Turn
  require 'turn/runners/isorunner'

  # = Cross Runner
  #
  # Cross Runner runs test in pairs.
  #
  class CrossRunner < IsoRunner

    #
    def start
      suite = TestSuite.new

      files = @controller.files
      viles = @controller.files # TODO: viles this selectable

      #files = files.select{ |f| File.extname(f) == '.rb' and File.file?(f) }
      #viles = viles.select{ |f| File.extname(f) == '.rb' and File.file?(f) }

      max = (files+viles).collect{ |f| f.size }.max

      pairs = files.inject([]){ |m, f| viles.collect{ |g| m << [f,g] }; m }
      #pairs = pairs.reject{ |f,v| f == v }

      testruns = pairs.collect do |file, versus|
        name = "%-#{max}s %-#{max}s" % [file, versus]
        suite.new_case(name, file, versus)
      end

      test_loop_runner(suite)
    end

  end

end

=begin
    #include Turn::Colorize

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
    # library compatibility. Each pair is run in a separate interpretor
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

      #testruns = pairs.collect do |pair|
      #  { 'file'    => pair,
      #    'command' => cmd % pair,
      #    'display' => dis % pair
      #  }
      #end

      testruns = pairs.collect do |pair|
        TestRun.new(dis % pair, cmd % pair)
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
=end
