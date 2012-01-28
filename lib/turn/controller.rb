module Turn

  # Controls execution of test run.
  #
  class Controller

    #
    def initialize(config=Turn.config)
      @config = config
    end

    #
    attr :config

    #
    def start
      if config.files.empty?
        $stderr.puts "No tests."
        return
      end

      setup

      testrun = runner.new
      testrun.start
    end

    #
    def setup
      config.loadpath.each{ |path| $: << path } unless config.live?
      config.requires.each{ |path| require(path) }
      config.files.each{ |path| require(path) }
    end

    # Insatance of Runner, selected based on format and runmode.
    def runner
      @runner ||= (
        case config.framework
        when :minitest
          require 'turn/runners/minirunner'
        else
          require 'turn/runners/testrunner'
        end

        case config.runmode
        when :marshal
          if config.framework == :minitest
            Turn::MiniRunner
          else
            Turn::TestRunner
          end
        when :solo
          require 'turn/runners/solorunner'
          Turn::SoloRunner
        when :cross
          require 'turn/runners/crossrunner'
          Turn::CrossRunner
        else
          if config.framework == :minitest
            Turn::MiniRunner
          else
            Turn::TestRunner
          end
        end
      )
    end

  end

end
