# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "riaktivity/version"

Gem::Specification.new do |s|
  s.name        = "riaktivity"
  s.version     = Riaktivity::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Mathias Meyer"]
  s.email       = ["meyer@paperplanes.de"]
  s.homepage    = ""
  s.summary     = %q{A tiny library to manage activity feeds in Riak.}
  s.description = %q{A tiny library to manage activity feeds in Riak.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "riak-client"
  s.add_development_dependency "rspec"
  s.add_development_dependency "active_support"
end
