require 'common/puppet_compiler'
require 'fileutils'

module Validator
  class Module
    include PuppetCompiler
    def initialize module_name
      @modulle = module_name.split("-")[1] || module_name
    end

    def run_tests(location = ".")
      results = {}
      modules = Locater.find_modules(location)
      module_root = modules.map{|module_dir| File.join(module_dir, @modulle)}.select{|modulle| File.exists?(modulle)}.first
      Locater.find_test_manifests(module_root).each do |test|
        setup_module test, modules
        test_name = File.basename(test)
        begin
          compile_catalog(test_name, location)
          results[test_name] = "[SUCCESS]"
        rescue => error
          results[test_name] = "[FAILURE] => #{error.message}"
        end
      end
      results
    end

    def test_module(location = ".")
      begin
        setup_modulepath
        run_tests(location)
      ensure
        cleanup_modulepath
      end
    end

    private

    def setup_modulepath
      temp_modules = File.join(".", "tempdir", "modules", @modulle)
      FileUtils.mkdir_p(temp_modules)
      ["manifests", "files", "templates", "tests"].each do |link|
        File.symlink(File.join("..", "..", "..", link), File.join(temp_modules, link)) if File.directory?(link)
      end
    end

    def cleanup_modulepath
      FileUtils.rm_rf "tempdir" if File.directory?("tempdir")
    end

    def setup_module test_location, module_path
      Puppet[:noop] = true
      Puppet[:pluginsync] = true
      Puppet.settings[:config] = File.join(File.dirname(__FILE__), "..", "resources", "puppet.conf.empty")
      Puppet.settings[:manifest] = test_location
      Puppet.settings[:modulepath] =  module_path.join(File::PATH_SEPARATOR)
    end

    def display results
      display = "\n"
      results.each do |result|
        display << "\t[#{result[:level].to_s.upcase}]: #{result[:message]}\n"
      end
      display
    end

  end
end
