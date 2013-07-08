build_number = ENV["BUILD_NUMBER"] || "local"

Gem::Specification.new do |spec|
  spec.name="puppet-validator"
  spec.version="2.0.0"
  spec.date="2013-03-07"
  spec.summary="provides functionality to validate and test puppet manifests"
  spec.description="combines functionality in puppet-lint, puppet verify and puppet compile to provide a way of testing puppet code prior to pushing it live"
  spec.homepage="https://github.com/oldNoakes/puppet-validator"
  spec.authors="Andrew Cunningham"
  spec.email="old.noakes@gmail.com"
  spec.files=Dir["lib/**/*"]
  spec.require_paths=["lib"]
  spec.add_dependency "puppet", "~> 2.7.21"
  spec.add_dependency "puppet-lint", ">= 0.3.2"
  spec.add_dependency "hiera-puppet"
  spec.add_dependency "facter"
  spec.add_dependency "librarian-puppet"
  spec.add_dependency "rake"
  spec.add_dependency "activerecord", ">= 2.1"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec_junit_formatter"
  spec.add_development_dependency "geminabox"
end
