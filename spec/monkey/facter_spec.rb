require 'monkey/facter'

describe "Facter monkey patch" do
  describe "overriding facts" do
    it "should override values using the common overrides yaml" do
      Facter.override_facts("test_node_no_override", File.join(File.dirname(__FILE__), "resources"))
      Facter.to_hash['operatingsystem'].should == "TestOS"
    end

    it "should override values using the node specific overrides yaml" do
      Facter.override_facts("test_node", File.join(File.dirname(__FILE__), "resources"))
      Facter.to_hash['architecture'].should == "x86_16"
    end

    it "should override common with node specific if both exist" do
      Facter.override_facts("test_node", File.join(File.dirname(__FILE__), "resources"))
      Facter.to_hash['ipaddress'].should == "50.50.50.50"
    end
  end
end
