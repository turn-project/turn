module Turn

  # For TestUnit 1.x, completely outdated.
  def self.bootstrap_legacy(autorun=false)
    require 'fileutils'

    require 'turn/version'
    require 'turn/autoload'
    require 'turn/configuration'
    require 'turn/colorize'
    require 'turn/components'
    require 'turn/controller'

    require 'test/unit'
    require 'turn/runners/testrunner'

    # need to turn this off unless autorun mode
    Test::Unit.run = autorun
  end

end

Turn.bootstrap_legacy(true)

