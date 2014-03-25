# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "turn/version"

Gem::Specification.new do |spec|
  spec.name          = "turn"
  spec.version       = Turn::VERSION
  spec.authors       = ["Tim Pease", "Thomas Sawyer"]
  spec.email         = ["tim.pease@gmail.com", "transfire@gmail.com"]
  spec.description   = %q{Turn provides a set of alternative runners for MiniTest, both colorful and informative.}
  spec.summary       = %q{Turn provides a set of alternative runners for MiniTest, both colorful and informative.}
  spec.homepage      = "https://github.com/turn-project/turn"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 1.9.2"

  spec.add_runtime_dependency "bundler", ">= 1.3"
  spec.add_runtime_dependency "ansi", ">= 1.1"
  spec.add_runtime_dependency "minitest", "~> 4"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
end
