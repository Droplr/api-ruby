# -*- encoding: utf-8 -*-
require File.expand_path('../lib/droplr/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Joshua Cody"]
  gem.email         = ["joshcody@droplr.com"]
  gem.summary        = "A ruby wrapper for the Droplr API"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "droplr"
  gem.require_paths = ["lib"]
  gem.version       = Droplr::VERSION

  gem.add_dependency("faraday")
  gem.add_dependency("json")

  gem.add_development_dependency("rspec")
end