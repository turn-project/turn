begin
  require 'ansi/code'
rescue LoadError
  begin
    require 'rubygems'
    require 'ansi/code'
  rescue LoadError
  end
end

module Turn

  module Colorize

    COLORLESS_TERMINALS = ['dumb']

    def colorize?
      defined?(::ANSI::Code) &&
        ENV.has_key?('TERM') &&
        !COLORLESS_TERMINALS.include?(ENV['TERM']) &&
        $stdout.tty?
    end
    module_function :colorize?

    def self.red(string)
      colorize? ? ::ANSI::Code.red{ string } : string
    end

    def self.green(string)
      colorize? ? ::ANSI::Code.green{ string } : string
    end

    def self.blue(string)
      colorize? ? ::ANSI::Code.blue{ string } : string
    end

    def self.magenta(string)
      colorize? ? ::ANSI::Code.magenta{ string } : string
    end

    def self.bold(string)
      colorize? ? ::ANSI::Code.bold{ string } : string
    end

    def self.pass(string)
      colorize? ? ::ANSI::Code.green{ string } : string
    end

    def self.fail(string)
      colorize? ? ::ANSI::Code.red{ string } : string
    end

    def self.skip(string)
      colorize? ? ::ANSI::Code.blue{ string } : string
    end

    #def self.error(string)
    #  colorize? ? ::ANSI::Code.white{ ::ANSI::Code.on_red{ string } } : string
    #end

    def self.error(string)
      colorize? ? ::ANSI::Code.yellow{ string } : string
    end

    def self.skip(string)
      colorize? ? ::ANSI::Code.cyan{ string } : string
    end

    PASS  = pass('PASS')
    FAIL  = fail('FAIL')
    ERROR = error('ERROR')
    SKIP  = skip('SKIP')

  end

end

