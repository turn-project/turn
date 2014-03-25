require "bundler/gem_tasks"

task :default => :test

desc "Run unit tests"
task :test do
  ruby "-Ilib bin/turn -Ilib -v test/*.rb"
end
