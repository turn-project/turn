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

      #testrun = runner.new
      #testrun.start

      Minitest.autorun
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
        require 'turn/runners/minirunner'

        case config.runmode
        when :marshal
          Turn::MiniRunner
        when :solo
          require 'turn/runners/solorunner'
          Turn::SoloRunner
        when :cross
          require 'turn/runners/crossrunner'
          Turn::CrossRunner
        else
          Turn::MiniRunner
        end
      )
    end

  end

end
