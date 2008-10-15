require 'turn/runners/isorunner'

module Turn

  # Iso Runner provides means from running unit test
  # in isolated processes. It can do this either by running
  # each test in isolation (solo testing) or in pairs (cross testing).
  #
  # The IsoRunner proiveds some variery in ouput formats and can also
  # log results to a file.

  class SoloRunner < IsoRunner

    #include Turn::Colorize

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

      #
      def initialize_defaults
        super
        @log      ||= false
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

    public
    # Run unit-tests. Each test is run in a separate interpretor
    # to prevent script clash. This makes for a more robust test
    # facility and prevents potential conflicts between test scripts.
    #
    #   tests     Test files (eg. test/tc_**/*.rb) [test/**/*]
    #   loadpath  Directories to include in load path [lib].
    #   require   List of files to require prior to running tests.
    #   live      Deactive use of local libs and test against install.

    def run_tests(options={})
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

      #testruns = files.collect do |file|
      #  { 'files'   => file,
      #    'command' => cmd % file,
      #    'display' => dis % file
      #  }
      #end

      suite = TestSuite.new

      testruns = files.collect do |file|
        suite.new_case(file, cmd % file)
      end

      report = test_loop_runner(suite)

      #puts report

      #log = false # TODO!!!!!!!!!!!!
      #log_report(report) if log
    end

  end

end

