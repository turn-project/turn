
begin
  require 'bones'
  Bones.setup
rescue LoadError
  load 'tasks/setup.rb'
end

task :default => 'test'

PROJ.name = 'turn'
PROJ.summary = 'Test::Unit Reporter (New) -- new output format for Test::Unit'
PROJ.authors = 'Tim Pease'
PROJ.email = 'tim.pease@gmail.com'
PROJ.url = 'http://codeforpeople.rubyforge.org/turn'
PROJ.version = '0.4.0'

PROJ.rubyforge.name = 'codeforpeople'

PROJ.rdoc.exclude << '^lib/'
PROJ.rdoc.remote_dir = PROJ.name

PROJ.ann.email[:server] = 'smtp.gmail.com'
PROJ.ann.email[:port] = 587
PROJ.ann.email[:from] = 'Tim Pease'

# EOF
