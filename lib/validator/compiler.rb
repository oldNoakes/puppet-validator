require 'puppet'
require 'hiera_puppet'
require 'facter'
require 'benchmark'
require 'yaml'
require 'validator/exceptions'
require 'common/locater'
require 'common/puppet_compiler'
require 'monkey/puppet'

module Validator
  class Compiler
    include PuppetCompiler

    def initialize compiler_hash = {}
      @nodename_filter = compiler_hash[:filter] || ".*"
      @location = compiler_hash[:location] || "."
      @verbose = compiler_hash[:verbose].nil? ? true : compiler_hash[:verbose]
    end

    def compile
      require 'monkey/hiera'

      setup_compile Locater.find_site_manifest(@location), Locater.find_modules(@location)
      all_nodes = collect_puppet_nodes

      raise "No nodes found to compile" if all_nodes.empty?
      subnodes = split_nodes all_nodes

      log "Found: #{all_nodes.length} nodes to evaluate - breaking them into #{subnodes.length} groups for compilation"

      build_successful = true
      time = Benchmark.realtime do
        subnodes.each do |nodegroup|
          nodegroup_successful = true
          fork {
            results = {}
            nodegroup.each do |node|
              begin
                evaluate_catalog(node, @location)
                log "* #{node} [ok]"
              rescue PuppetWarning => warning
                log "* #{node} [WARNING] #{warning.message}}"
              rescue => error
                log "* #{node} [FAILED]\n\t=> #{error.message}"
                nodegroup_successful = false
              end
            end
            exit 1 unless nodegroup_successful
          }
        end

        subnodes.each {
          pid, status = Process.wait2
          build_successful  = false unless status.exitstatus == 0
        }
      end
      log "Completed compiling all nodes - took #{time} seconds"
      raise CompilationFailure.new("[BUILD FAILED] check the output for details") unless build_successful
    end

    def evaluate_catalog(nodename, location = ".")
      results = setup_logger(:array_hash)
      compile_catalog(nodename, location)
      evaluate_catalog_results results
    end

    def evaluate_catalog_results results
      warnings = ""
      results.warnings.each do |warning|
        warnings << "\n\t" + warning unless ignore_warning warning
      end
      raise PuppetWarning.new(warnings) unless warnings.nil? || warnings.empty?
    end

    def ignore_warning warning_msg
      ignore_all = false
      [/without storeconfigs being set/,
       /Unrecognised escape sequence/,
       /Not collecting exported resources/,
      ].each do |ignore|
        ignore_all = true if warning_msg =~ ignore
      end
      ignore_all
    end

    def setup_compile manifest_path, module_path
      Puppet.settings[:config] = File.join(File.dirname(__FILE__), "..", "resources", "puppet.conf.empty")
      Puppet.settings[:manifestdir] = manifest_path
      Puppet.settings[:modulepath] =  module_path.join(File::PATH_SEPARATOR)
    end

    def log log_message
      puts log_message if @verbose
    end

    def split_nodes node_array
      chunks = read_override_file("chunks") || number_cpus
      slice_size = (node_array.length/Float(chunks)).ceil
      node_array.sort.each_slice(slice_size).to_a
    end

    def read_override_file key
      overrides = File.join(@location, ".compile", "compile_overrides.yaml")
      File.exists?(overrides) ? YAML.load_file(overrides)[key] : nil
    end

    def number_cpus
      Facter.loadfacts
      Facter.processorcount.to_i
    end

    def collect_puppet_nodes
      parser = Puppet::Parser::Parser.new("environment")
      nodes = parser.environment.known_resource_types.nodes.keys
      nodes = nodes.reject { |node| node == "default" }
      nodes.select { |node| node =~ /#{@nodename_filter}/ }
    end
  end
end
