# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "adhearsion_restful_rpc/version"

Gem::Specification.new do |s|
  s.name        = "adhearsion_restful_rpc"
  s.version     = AdhearsionRestfulRpc::VERSION
  s.authors     = ["Adhearsion Team+Shirshendu Mukherjee"]
  s.email       = ["shirshendu.mukherjee.88@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Adhearsion Restful RPC working with adhearsion 2.0}
  s.description = %q{Working on this independently, no affiliation with Adhearsion formally (yet), but all my respects to them and their code.}

  s.rubyforge_project = "adhearsion_restful_rpc"

  # Use the following if using Git
  # s.files         = `git ls-files`.split("\n")
  # s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.files         = Dir.glob("{lib}/**/*") + %w( README.md Rakefile Gemfile)
  s.test_files    = Dir.glob("{spec}/**/*")
  s.require_paths = ["lib"]

  s.add_runtime_dependency %q<adhearsion>, ["~> 2.1"]
  s.add_runtime_dependency %q<activesupport>, [">= 3.0.10"]

  s.add_development_dependency %q<bundler>, ["~> 1.0"]
  s.add_development_dependency %q<rspec>, ["~> 2.5"]
  s.add_development_dependency %q<rake>, [">= 0"]
  s.add_development_dependency %q<mocha>, [">= 0"]
  s.add_development_dependency %q<guard-rspec>
 end
