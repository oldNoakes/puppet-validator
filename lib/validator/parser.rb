require 'puppet'
require 'puppet/face'
require 'common/verifyer'

module Validator
  class Parser
    include Verifyer

    def initialize location
      @location = location || "."
      @type = :validate
    end

    def execute manifest
      results = { :warning => [], :error => [] }

      setup_puppet_array_logger(results[:warning])
      Puppet.settings.handlearg("--storeconfigs")
      begin
        Puppet::Face[:parser, '0.0.1'].validate(manifest)
      rescue Exception => e
        results[:error] << e.message
      end
      results[:warning].collect! { |log| "#{log.level}: #{log.message}" }
      results
    end

    private
    def setup_puppet_array_logger(array)
      # The array logger maintains state so we need to close all before creating a new one
      Puppet::Util::Log.close_all

      collector = Puppet::Test::LogCollector.new(array)
      Puppet::Util::Log.newdestination(collector)
    end
  end
end
