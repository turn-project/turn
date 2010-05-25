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

    COLORIZE = defined?(::ANSI::Code) && ENV.has_key?('TERM')

    if COLORIZE
      PASS  = ::ANSI::Code.green{ 'PASS' }
      FAIL  = ::ANSI::Code.red{ 'FAIL' }
      ERROR = ::ANSI::Code.white{ ::ANSI::Code.on_red{ 'ERROR' } }
    else
      PASS  = "PASS"
      FAIL  = "FAIL"
      ERROR = "ERROR"
    end

    def self.red(string)
      COLORIZE ? ::ANSI::Code.red{ string } : string
    end

    def self.green(string)
      COLORIZE ? ::ANSI::Code.green{ string } : string
    end

    def self.blue(string)
      COLORIZE ? ::ANSI::Code.blue{ string } : string
    end

    def self.magenta(string)
      COLORIZE ? ::ANSI::Code.magenta{ string } : string
    end

  end

end
