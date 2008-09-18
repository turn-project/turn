begin
  require 'facets/ansicode'
rescue LoadError
  begin
    require 'rubygems'
    require 'facets/ansicode'
  rescue LoadError
  end
end

module Turn
  
  module Colorize

    COLORIZE = defined?(::ANSICode) && ENV.has_key?('TERM')

    if COLORIZE
      PASS  = ::ANSICode.green('PASS')
      FAIL  = ::ANSICode.red('FAIL')
      ERROR = ::ANSICode.white(::ANSICode.on_red('ERROR'))
    else
      PASS  = "PASS"
      FAIL  = "FAIL"
      ERROR = "ERROR"
    end

  end

end
