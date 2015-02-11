# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sso_client/version'

Gem::Specification.new do |spec|
  spec.name          = "sso_client"
  spec.version       = SsoClient::VERSION
  spec.authors       = ["Rudy Seidinger"]
  spec.email         = ["rudyseidinger@gmail.com"]
  spec.summary       = "Innvet SSO Client"
  spec.description   = "A rubygem that wraps a client for the InnventSSOServer gem"
  spec.homepage      = ""
  spec.license       = "Copyright Innvent 2014"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_dependency "rails"         , ">= 3.1"
  spec.add_dependency "httparty"
end
