# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'viperaptor/version'

Gem::Specification.new do |spec|
  spec.name          = 'viperaptor'
  spec.version       = Viperaptor::VERSION
  spec.authors       = ['Siarhei Ladzeika']
  spec.email         = 'sergey.ladeiko@gmail.com'

  spec.summary       = 'Advanced code generator for Xcode projects with a nice and flexible template system.'
  spec.description   = 'New reincarnation of Rambler Generamba tool (original code got from Generamba)'
  spec.homepage      = 'https://github.com/ladeiko/Viperaptor'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = ['viperaptor']
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.3'

  spec.add_runtime_dependency 'thor', '1.2.1'
  spec.add_runtime_dependency 'xcodeproj', '1.21.0'
  spec.add_runtime_dependency 'liquid', '5.1.0'
  spec.add_runtime_dependency 'git', '1.10.2'
  spec.add_runtime_dependency 'cocoapods-core', '1.11.2'
  spec.add_runtime_dependency 'terminal-table', '3.0.2'
  spec.add_runtime_dependency 'tty-prompt', '~> 0.23.1'

  spec.add_development_dependency 'bundler', '>= 1.16'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.7'
  spec.add_development_dependency 'fakefs', '~> 1.3'
  spec.add_development_dependency 'activesupport', '~> 5.2'
end
