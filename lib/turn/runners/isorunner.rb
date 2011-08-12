module Turn
  require 'turn/colorize'
  require 'yaml'
  require 'open3'

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

    def initialize
      @config = Turn.config

      @reporter = @config.reporter
      #yield(self) if block_given?
      @loadpath = @config.loadpath
      @requires = @config.requires
      @live     = @config.live?
      @minitest = @config.framework == :minitest
    end

  public

    # Runs the list of test calls passed to it.
    # This is used by #test_solo and #test_cross.
    #
    def start
      suite = TestSuite.new
      testruns = @config.files.collect do |file|
        name = file.sub(Dir.pwd+'/','')
        suite.new_case(name, file)
      end
      test_loop_runner(suite)
    end

  private

    # The IsoRunner actually shells out to turn in
    # manifest mode, to gather results from isolated
    # runs.
    def test_loop_runner(suite)
      reporter.start_suite(suite)

      recase = []

      suite.each_with_index do |kase, index|
        reporter.start_case(kase)

        turn_path = File.expand_path(File.dirname(__FILE__) + '/../bin.rb')

        files = kase.files.map{ |f| f.sub(Dir.pwd+'/', '') }

        # FRACKING GENIUS RIGHT HERE !!!!!!!!!!!!
        cmd = []
        cmd << "ruby"
        cmd << "-I#{@loadpath.join(':')}" unless @loadpath.empty?
        cmd << "-r#{@requires.join(':')}" unless @requires.empty?
        cmd << "--"
        cmd << turn_path
        cmd << "--marshal"
        cmd << %[--loadpath="#{@loadpath.join(':')}"] unless @loadpath.empty?
        cmd << %[--requires="#{@requires.join(':')}"] unless @requires.empty?
        cmd << "--live" if @live
        cmd << "--minitest" if @minitest
        cmd << files.join(' ')
        cmd = cmd.join(' ')

        #out = `#{cmd}`
        #err = ''

        out, err = nil, nil
        Open3.popen3(cmd) do |stdin, stdout, stderr|
          stdin.close
          out = stdout.read.chomp
          err = stderr.read.chomp
        end

        # TODO: how to report? will need to add something to reporter
        # b/c it may have redirected stdout. Or use STDOUT?
        #if !err.empty?
        #  puts err
        #  raise
        #end

        files = kase.files

        # remove any unexpected output injected at the beginning
        b = out.index(/^---/)
        yaml = out[b..-1]
        sub_suite = YAML.load(yaml)

        # TODO: How to handle pairs?
        #name  = kase.name
        kases = sub_suite.cases
        suite.cases[index] = kases

        kases.each do |kase|
          kase.files = files
          #reporter.start_case(kase)
          kase.tests.each do |test|
            reporter.start_test(test)
            if test.error?
              #reporter.error(test.message)
              reporter.error(test.raised)
            elsif test.fail?
              #reporter.fail(test.message)
              reporter.error(test.raised)
            else
              reporter.pass
            end
            reporter.finish_test(test)
          end
          reporter.finish_case(kase)
        end
      end

      suite.cases.flatten!

      reporter.finish_suite(suite)

      # shutdown auto runner
      if @minitest

      else
        ::Test::Unit.run=true rescue nil
      end

      suite
    end

    #
    #def test_parse_result(result)
    #  if md = /(\d+) tests, (\d+) assertions, (\d+) failures, (\d+) errors/.match(result)
    #    count = md[1..4].collect{|q| q.to_i}
    #  else
    #    count = [1, 0, 0, 1]  # SHOULD NEVER HAPPEN
    #  end
    #  return count
    #end

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
