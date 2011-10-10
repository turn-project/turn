# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{turn}
  s.version = "0.8.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Tim Pease}]
  s.date = %q{2011-10-10}
  s.description = %q{}
  s.email = %q{tim.pease@gmail.com}
  s.executables = [%q{turn}]
  s.extra_rdoc_files = [%q{History.txt}, %q{NOTICE.txt}, %q{Release.txt}, %q{Version.txt}, %q{bin/turn}, %q{license/GPLv2.txt}, %q{license/MIT-LICENSE.txt}, %q{license/RUBY-LICENSE.txt}]
  s.files = [%q{.travis.yml}, %q{Gemfile}, %q{History.txt}, %q{NOTICE.txt}, %q{README.md}, %q{Rakefile}, %q{Release.txt}, %q{Version.txt}, %q{bin/turn}, %q{demo/test_autorun_minitest.rb}, %q{demo/test_autorun_testunit.rb}, %q{demo/test_counts.rb}, %q{demo/test_sample.rb}, %q{demo/test_sample2.rb}, %q{lib/turn.rb}, %q{lib/turn/autoload.rb}, %q{lib/turn/autorun/minitest.rb}, %q{lib/turn/autorun/minitest0.rb}, %q{lib/turn/autorun/testunit.rb}, %q{lib/turn/autorun/testunit0.rb}, %q{lib/turn/bin.rb}, %q{lib/turn/colorize.rb}, %q{lib/turn/command.rb}, %q{lib/turn/components/case.rb}, %q{lib/turn/components/method.rb}, %q{lib/turn/components/suite.rb}, %q{lib/turn/controller.rb}, %q{lib/turn/core_ext.rb}, %q{lib/turn/reporter.rb}, %q{lib/turn/reporters/cue_reporter.rb}, %q{lib/turn/reporters/dot_reporter.rb}, %q{lib/turn/reporters/marshal_reporter.rb}, %q{lib/turn/reporters/outline_reporter.rb}, %q{lib/turn/reporters/pretty_reporter.rb}, %q{lib/turn/reporters/progress_reporter.rb}, %q{lib/turn/runners/crossrunner.rb}, %q{lib/turn/runners/isorunner.rb}, %q{lib/turn/runners/loadrunner.rb}, %q{lib/turn/runners/minirunner.rb}, %q{lib/turn/runners/solorunner.rb}, %q{lib/turn/runners/testrunner.rb}, %q{lib/turn/version.rb}, %q{license/GPLv2.txt}, %q{license/MIT-LICENSE.txt}, %q{license/RUBY-LICENSE.txt}, %q{test/helper.rb}, %q{test/runner}, %q{test/test_framework.rb}, %q{test/test_reporters.rb}, %q{test/test_runners.rb}, %q{turn.gemspec}]
  s.homepage = %q{http://gemcutter.org/gems/turn}
  s.rdoc_options = [%q{--main}, %q{README.md}]
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{turn}
  s.rubygems_version = %q{1.8.6}
  s.summary = %q{Test::Unit Reporter (New) -- new output format for Test::Unit}
  s.test_files = [%q{test/test_framework.rb}, %q{test/test_reporters.rb}, %q{test/test_runners.rb}]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ansi>, [">= 0"])
      s.add_development_dependency(%q<bones-git>, [">= 1.2.4"])
      s.add_development_dependency(%q<bones>, [">= 3.7.1"])
    else
      s.add_dependency(%q<ansi>, [">= 0"])
      s.add_dependency(%q<bones-git>, [">= 1.2.4"])
      s.add_dependency(%q<bones>, [">= 3.7.1"])
    end
  else
    s.add_dependency(%q<ansi>, [">= 0"])
    s.add_dependency(%q<bones-git>, [">= 1.2.4"])
    s.add_dependency(%q<bones>, [">= 3.7.1"])
  end
end
