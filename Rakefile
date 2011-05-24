require 'rubygems'

gemfile = File.expand_path('../Gemfile', __FILE__)
begin
  ENV['BUNDLE_GEMFILE'] = gemfile
  require 'bundler'
  Bundler.setup
rescue Bundler::GemNotFound => e
  STDERR.puts e.message
  STDERR.puts "Try running `bundle install`."
  exit!
end if File.exist?(gemfile)

require 'bones'

task :default => 'test'

Bones {
  name         'turn'
  summary      'Test::Unit Reporter (New) -- new output format for Test::Unit'
  authors      'Tim Pease'
  email        'tim.pease@gmail.com'
  url          'http://gemcutter.org/gems/turn'
  version      File.read('Version.txt').strip
  ignore_file  '.gitignore'

  exclude      << '^work'
  rdoc.exclude << '^lib'

  use_gmail

  depend_on 'ansi'
  depend_on 'bones-git', :development => true
}

# Might be useful one day, so we'll leave it here.
#
# Rake::TaskManager.class_eval do
#   def remove_task(task_name)
#     @tasks.delete(task_name.to_s)
#   end
# end
#
# def remove_task(task_name)
#   Rake.application.remove_task(task_name)
# end

# EOF
