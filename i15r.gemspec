# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'i15r/version'

Gem::Specification.new do |gem|
  gem.name          = "i15r"
  gem.version       = I15R::VERSION
  gem.authors       = ["Balint Erdi"]
  gem.email         = ["balint.erdi@gmail.com"]
  gem.description   = %q{The internationalizer. Replaces plain text strings in your views and replaces them with I18n message strings so you only have to provide the translations.}
  gem.summary       = %q{Eases the pain of moving to I18n view templates}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'rake', ['~> 10.0.3']
  gem.add_development_dependency 'rspec', ['~> 2.12.0']
  gem.add_development_dependency 'guard', ['~> 1.5.4']
  gem.add_development_dependency 'guard-rspec', ['~> 2.3.1']
  gem.add_development_dependency 'rb-fsevent', ['~> 0.9.1']
end

