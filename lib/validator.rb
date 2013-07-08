require 'validator/lint'
require 'validator/parser'
require 'validator/compiler'
require 'validator/librarian'
require 'validator/test_librarian'
require 'validator/static_analysis_report'
require 'validator/module'

namespace :validator do
  desc "Pre-commit verification of puppet code - runs puppet-lint and puppet verify"
  task :verify, [:location] => ["validator:clean", "validator:librarian"] do |task, args|
    args.with_defaults(:location => ".")
    location = File.expand_path(args[:location])

    lint_results = Validator::Lint.new(location).run
    parse_results = Validator::Parser.new(location).run

    syntax_results = merge_hash_recursive(lint_results, parse_results)
    failures = Validator::StaticAnalysisReport.new("#{location}/build/reports/").analyse(syntax_results)

    unless failures.empty?
      puts "The following puppet manifests have exceeded the threshhold for allowed verification/lint issues - please rectify:"
      failures.each do |failure|
        puts "\t#{failure[0]} failed to pass with a total score of: #{failure[1][:score]} - see detailed report here: #{failure[1][:href].sub("./", "./build/reports/")}"
      end
      fail "Validator verify failed"
    end
  end

  desc "Pre-commit compilation of puppet code - if you only want to compile specific nodes, add a regex filter to select the nodes"
  task :compile, [:filter, :location] => ["validator:clean", "validator:librarian"] do |task, args|
    compiler = Validator::Compiler.new({:filter => args[:filter], :location => args[:location], :verbose => true})
    compiler.compile
  end

  namespace :module do

    desc "Pre-commit validation of a shared module"
    task :compile, [:module_name] => ["validator:clean", "validator:module:librarian"] do |task, args|
      args.with_defaults(:module_name => File.basename(Dir.pwd))
      module_validator = Validator::Module.new(args.module_name)
      results = module_validator.test_module
      results.each do |key, value|
        puts "Test: #{key} => #{value}"
      end
    end

    task :librarian, [:module_name] do |task, args|
      args.with_defaults(:module_name => File.basename(Dir.pwd))
      location = File.expand_path(args.module_name)
      Validator::TestLibrarian.new(location).run
    end
  end


  task :librarian, :location do |task, args|
    args.with_defaults(:location => ".")
    location = File.expand_path(args[:location])

    Validator::Librarian.new(location).run
  end

  task :clean, :location do |task, args|
    args.with_defaults(:location => ".")
    location = File.expand_path(args[:location])
    build_dir = File.join(location, "build")

    FileUtils.rm_rf build_dir if File.exists?(build_dir)
    FileUtils.mkdir_p build_dir
  end

  def merge_hash_recursive(a ,b)
    a.merge(b) { |key, a_item, b_item| merge_hash_recursive(a_item, b_item) }
  end

  namespace :nolibrarian do
    desc "Pre-commit verification of puppet code with no automatic Librarian installation - runs puppet-lint and puppet verify"
    task :verify, [:location] do |task, args|
      Rake::Task["validator:verify"].prerequisites.replace(["validator:clean"])
      Rake::Task["validator:verify"].invoke(args[:location])
    end

    desc "Pre-commit compilation of puppet code with no automatic Librarian installation - if you only want to compile specific nodes, add a regex filter to select the nodes"
    task :compile, [:filter, :location] do |task, args|
      Rake::Task["validator:compile"].prerequisites.replace(["validator:clean"])
      Rake::Task["validator:compile"].invoke(args[:filter], args[:location])
    end
  end
end
