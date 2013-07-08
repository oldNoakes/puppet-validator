require 'puppet'
require 'puppet/face'
require 'monkey/puppet'
require 'monkey/facter'
require 'yaml'

module PuppetCompiler
  def compile_catalog(nodename, location = ".")
    require 'monkey/facter'
    Facter.override_facts(nodename, location)
    override_providers

    catalog = Puppet::Face[:catalog, '0.0.1'].find(nodename)

    # Cannot emulate a windows box on linux
    unless Facter.value("operatingsystem") == "windows"
      catalog = catalog.to_ral
      catalog.finalize

      relationship_graph = catalog.relationship_graph
      relationship_graph.report_cycles_in_graph
    end

    yield catalog if block_given?
  end

  def setup_logger(type, level = :info)
    Puppet::Util::Log.close_all
    Puppet::Util::Log.level = level
    Puppet::Util::Log.newdestination(type)
  end

  def override_providers
    # set the default package provider as yum (which can handle all package info)
    Puppet::Type.type(:package).defaultprovider = Puppet::Type.type(:package).provider(:yum)
    # set the default user provider as useradd (which can handle the most features)
    Puppet::Type.type(:user).defaultprovider = Puppet::Type.type(:user).provider(:useradd)
    # Set the default user as root
    Puppet.features.add(:root) { true }
  end
end
