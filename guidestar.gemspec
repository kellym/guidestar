# -*- encoding: utf-8 -*-
require File.expand_path('../lib/guidestar/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Kelly Martin']
  gem.email         = ['kellymartinv@gmail.com']
  gem.description   = "Allows access to the Guidestar API"
  gem.summary       = "Use this gem to access the Guidestar API"
  gem.homepage      = 'http://github.com/kellym/guidestar'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'guidestar'
  gem.require_paths = ['lib']
  gem.version       = Guidestar::VERSION

  gem.add_dependency 'faraday', '~> 0.8'
  gem.add_dependency 'faraday_middleware', '~> 0.9'
  gem.add_dependency 'rash', '~> 0.3'
  gem.add_dependency 'multi_xml', '~> 0.5'
  gem.add_dependency 'nokogiri', '~> 1.5'
end
