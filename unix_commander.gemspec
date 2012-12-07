# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'unix_commander/version'

Gem::Specification.new do |gem|
  gem.name          = "unix_commander"
  gem.version       = UnixCommander::VERSION
  gem.authors       = ["Lorenzo Lopez"]
  gem.email         = ["lorenzo.lopez@uk.tesco.com"]
  gem.description   = %q{A gem to run unix commands on a more ruby-esque way}
  gem.summary       = gem.description
  gem.homepage      = "https://github.com/Batou99/unix_commander"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency  "net-ssh", ">=2.6.2"
  gem.add_development_dependency "rspec", "~> 2.12"
  gem.add_development_dependency "pry"
  gem.add_development_dependency "simplecov"
  gem.add_development_dependency "pry-debugger"
  gem.add_development_dependency "guard-rspec"
  gem.add_development_dependency "rb-inotify"
  gem.add_development_dependency "rb-fsevent"
end
