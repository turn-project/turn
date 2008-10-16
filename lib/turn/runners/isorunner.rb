module Turn
  require 'turn/colorize'

  # = IsoRunner
  #
  # Iso Runner provides means from running unit test
  # in isolated processes. It can do this either by running
  # each test in isolation (solo testing) or in pairs (cross testing).
  #
  # The IsoRunner proiveds some variery in ouput formats and can also
  # log results to a file.
  #
  class IsoRunner
    include Turn::Colorize

    attr :reporter

  private

    def initialize(controller)
      @controller = controller
      @reporter   = controller.reporter
      #yield(self) if block_given?
      @loadpath = controller.loadpath
      @requires = controller.requires
      @live     = controller.live?
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

    # The IsoRunner actually shells out to turn in 
    # manifest mode, to gather results from isolated
    # runs.
    def test_loop_runner(suite)
      reporter.start_suite(suite)
      suite.each_with_index do |kase, index|
        reporter.start_case(kase)

        # FRACKING GENIUS RIGHT HERE !!!!!!!!!!!!
        cmd = []
        cmd << %[turn]
        cmd << %[--marshal]
        cmd << %[--loadpath="#{@loadpath.join(';')}"] unless @loadpath.empty?
        cmd << %[--requires="#{@requires.join(';')}"] unless @requires.empty?
        cmd << %[--live] if @live
        cmd << %[#{kase.files.join(' ')}]
        cmd = cmd.join(' ')
        result = `#{cmd}`

        head, yaml = *result.split('---')
        sub_suite = YAML.load(yaml)

        # TODO: handle multiple subcases
        name = kase.name
        kase = sub_suite.cases[0]
        kase.name = name
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

        reporter.finish_case(kase)
      end
      reporter.finish_suite(suite)

      # shutdown test/unit auto runner if test/unit is loaded.
      ::Test::Unit.run=true rescue nil
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

    # NOT USED YET.
    def log_report(report)
      if log #&& !dryrun?
        #logfile = File.join('log', apply_naming_policy('testlog', 'txt'))
        FileUtils.mkdir_p('log')
        logfile = File.join('log', 'testlog.txt')
        File.open(logfile, 'a') do |f|
          f << "= #{self.class} Test @ #{Time.now}\n"
          f << report
          f << "\n"
        end
      end
    end

  end#class IsoRunner

end#module Turn

