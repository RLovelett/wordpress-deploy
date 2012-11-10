# -*- encoding: utf-8 -*-
require File.expand_path('../lib/wordpress_deploy/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Ryan Lovelett"]
  gem.email         = ["ryan@lovelett.me"]
  gem.description   = %q{Wordpress Deploy provides an elegant DSL in Ruby for modeling and executing your deployments.}
  gem.summary       = %q{Wordpress Deploy is a RubyGem, written for Linux and Mac OSX, that allows you to easily perform Wordpress deployment operations. It provides you with an elegant DSL in Ruby for modeling your deployments.}
  gem.homepage      = %q{https://github.com/RLovelett/wordpress-deploy}

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "wordpress-deploy"
  gem.require_paths = ["lib"]
  gem.version       = WordpressDeploy::VERSION

  ##
  # Gem dependencies
  gem.add_dependency 'thor',               ['~> 0.15.4']
  gem.add_dependency 'colorize',           ['~> 0.5.8']
  gem.add_dependency 'titleize',           ['~> 1.2.1']
  gem.add_dependency 'actionpack',         ['~> 3.2.6']
  gem.add_dependency 'php-serialize_ryan', ['~> 1.1.0']
  gem.add_dependency 'mysql2',             ['~> 0.3.11']
  gem.add_dependency 'sequel',             ['~> 3.41.0']

  gem.add_development_dependency 'rake',                    ['~> 0.9.2.2']
  gem.add_development_dependency 'rspec',                   ['~> 2.11.0']
  gem.add_development_dependency 'guard-rspec',             ['~> 2.1.0']
  gem.add_development_dependency 'rb-fsevent',              ['~> 0.9.1']
  gem.add_development_dependency 'terminal-notifier-guard', ['~> 1.5.3']
  gem.add_development_dependency 'fakefs',                  ['~> 0.4.2']
  gem.add_development_dependency 'fake_ftp',                ['~> 0.0.9']
end
