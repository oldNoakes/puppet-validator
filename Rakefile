require 'rspec/core/rake_task'
require 'rake/clean'
require 'geminabox_client'

CLEAN.include 'build'
CLEAN.include '*.gem'

RSpec::Core::RakeTask.new(:spec) do |task|
  file_list = FileList["spec/**/*_spec.rb"].exclude("spec/functional/**/*_spec.rb")
  task.pattern = file_list
  task_formatter = ENV["RSPEC_JUNIT_FORMAT"] ? "--require rspec_junit_formatter --format RspecJunitFormatter -o ./build/rspec_results.xml" : "--format progress"
  task.rspec_opts = [task_formatter]
end

desc "Runs all functional test cases for puppet validator"
RSpec::Core::RakeTask.new(:functional) do |task|
  task.pattern = "spec/functional/**/*_spec.rb"
  task_formatter = ENV["RSPEC_JUNIT_FORMAT"] ? "--require rspec_junit_formatter --format RspecJunitFormatter -o ./build/rspec_results.xml" : "--format progress"
  task.rspec_opts = [task_formatter, "--tag ~broken"]
end

task :default => [:clean, :spec]

task :upload do
  build_number = ENV["BUILD_NUMBER"]
  raise "Locally built gems cannot be uploaded" if build_number.empty?

  gem = Dir.glob("**/*.#{build_number}.gem").first
  raise "Gem for build: #{build_number} does not exist" unless gem
  gem_location = File.expand_path(gem)

  # Read config file to get gemrepo location

  client = GeminaboxClient.new("")
  client.push gem_location
end
