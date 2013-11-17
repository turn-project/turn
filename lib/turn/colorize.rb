require 'turn/configuration'  # TODO: why is this needed here?

# TODO: adapt for Ruby 1.9+?
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

  # Provides a uniform interface for colorizing Turn output.
  #
  module Colorize

    def self.included(base)
      base.module_eval do
        const_set :PASS,  Colorize.pass('PASS')
        const_set :FAIL,  Colorize.fail('FAIL')
        const_set :ERROR, Colorize.error('ERROR')
        const_set :SKIP,  Colorize.skip('SKIP')
      end
    end

    COLORLESS_TERMINALS = ['dumb']

    # Colorize output or not?
    def self.colorize?
      return @colorize unless @colorize.nil?
      @colorize ||= (
        ansi = Turn.config.ansi?
        ansi.nil? ? color_supported? : ansi
      )
    end

    # Does the system support color?
    def self.color_supported?
      return false unless defined?(::ANSI::Code)
      return false unless $stdout.tty?
      return true if ENV.has_key?('TERM') && !COLORLESS_TERMINALS.include?(ENV['TERM'])
      return true if ::RbConfig::CONFIG['host_os'] =~ /mswin|mingw/ && ENV.has_key?('ANSICON')
      return false
    end

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

    def self.mark(string)
      colorize? ? ::ANSI::Code.yellow{ string } : string
    end

    def self.pass(string)
      colorize? ? ::ANSI::Code.green{ string } : string
    end

    def self.fail(string)
      colorize? ? ::ANSI::Code.red{ string } : string
    end

    def self.error(string)
      #colorize? ? ::ANSI::Code.white_on_red{ string } : string
      colorize? ? ::ANSI::Code.yellow{ string } : string
    end

    def self.skip(string)
      colorize? ? ::ANSI::Code.cyan{ string } : string
    end

    def colorize?
      Colorize.colorize?
    end

  end

end
