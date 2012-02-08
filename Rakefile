task :default => 'test'

desc "Run unit tests"
task :test do
  sh 'test/runner'
end

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
