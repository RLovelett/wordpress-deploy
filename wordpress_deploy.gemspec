# -*- encoding: utf-8 -*-
require File.expand_path('../lib/wordpress_deploy/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Ryan Lovelett"]
  gem.email         = ["ryan@wahvee.com"]
  gem.description   = %q{Used to deploy a Wordpress site.}
  gem.summary       = %q{}
  gem.homepage      = %q{https://github.com/RLovelett/jsb3}

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "wordpress-deploy"
  gem.require_paths = ["lib"]
  gem.version       = WordpressDeploy::VERSION

  gem.add_dependency 'thor',       ['~> 0.14.6']
  gem.add_dependency 'open4',      ['~> 1.3.0']
  gem.add_dependency 'actionpack', ['~> 3.2.6']
  gem.add_dependency 'colorize',   ['~> 0.5.8']
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
end
