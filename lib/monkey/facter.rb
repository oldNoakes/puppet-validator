require 'facter'
require 'hiera'

module Facter
  class << self
    alias_method :get_hash, :to_hash
    alias_method :get_value, :value
  end

  def self.override_facts(nodename, location)
    # Need to determine better impl
    @facts = Puppet::Node::Facts.indirection.find(nodename).values
    @facts = @facts.merge({
      'architecture'    => 'x86_64',
      'operatingsystem' => 'CentOS',
      'ipaddress'       => '127.0.0.1',
      'hostname'        => "#{nodename.split('.').first}",
      'fqdn'            => nodename,
      'domain'          => 'dummy.domain',
      'netmask'         => '255.255.255.0' })
    site_overrides = File.join(location, ".compile", "facter_overrides.yaml")
    node_overrides = File.join(location, ".compile", "#{nodename}.yaml")

    @facts = @facts.merge(YAML.load_file(site_overrides)) if File.exists?(site_overrides)
    @facts = @facts.merge(YAML.load_file(node_overrides)) if File.exists?(node_overrides)
  end

  def self.to_hash
    @facts ||= Facter.get_hash
  end

  def self.value search
    if @facts
      @facts[search]
    else
      Facter.get_value search
    end
  end
end
