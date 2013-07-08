require 'common/directory_builder'
require 'common/verifyer'
include DirectoryBuilder

class Testclass
  include Verifyer
end

describe "Verify file accumulator" do
  before(:each) do
    @root_dir = File.join(File.dirname(__FILE__), 'tmp')
    build_directory_structure @root_dir
    @test = Testclass.new
  end

  after(:each) do
    FileUtils.rm_rf @root_dir if File.exist?(@root_dir)
  end

  it "should find all valid manifests if given a directory" do
    build_directory_structure "site/modules/httpd/manifests", "site/modules/tomcat/manifests", "manifests/nodes"
    add_files "site/modules/httpd/manifests", "init.pp", "vhost.pp", "mod_ssl.pp"
    add_files "site/modules/tomcat/manifests", "setup.pp", "user.pp"
    add_files "manifests/nodes", "node1.pp", "node2.pp"

    @test.get_files_from(@root_dir).size.should == 7
  end

  it "should return an array with a single file if given a file" do
    add_files ".", "init.pp"
    @test.get_files_from(File.join(@root_dir, "init.pp")).size.should == 1
  end

  it "should raise an exception if given a non-existent location" do
    lambda { @test.get_files_from(File.join(@root_dir, "fake")) }.should raise_exception
  end
end
