# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'multipass/version'

Gem::Specification.new do |spec|
  spec.name          = "multipass"
  spec.version       = MultiPass::VERSION
  spec.authors       = ["Rick Olson", "Eaden McKee"]
  spec.email         = ["technoweenie@gmail.com", "eaden@coinjar.com"]
  spec.summary       = %q{Bare bones implementation of encoding and decoding MultiPass values for SSO.}
  spec.description   = %q{SSO multipass}
  spec.homepage      = "https://github.com/eadz/multipass"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "activesupport"
end
