begin
  require 'bones'
rescue LoadError
  abort '### please install the "bones" gem ###'
end

task :default => 'test'

Bones {
  name         'turn'
  summary      'Test::Unit Reporter (New) -- new output format for Test::Unit'
  authors      'Tim Pease'
  email        'tim.pease@gmail.com'
  url          'http://gemcutter.org/gems/turn'
  version      File.read('Version.txt').strip
  ignore_file  '.gitignore'
  rubyforge.name 'codeforpeople'

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
