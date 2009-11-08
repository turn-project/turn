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
      PASS  = ::ANSI::Code.green('PASS')
      FAIL  = ::ANSI::Code.red('FAIL')
      ERROR = ::ANSI::Code.white(::ANSI::Code.on_red('ERROR'))
    else
      PASS  = "PASS"
      FAIL  = "FAIL"
      ERROR = "ERROR"
    end

  end

end
