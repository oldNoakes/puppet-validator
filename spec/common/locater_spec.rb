require 'common/directory_builder'
require 'common/locater'
require 'fileutils'
include DirectoryBuilder

describe "puppet info locater" do
  before(:each) do
    @root_dir = File.join(File.dirname(__FILE__), 'tmp')
  end

  after(:each) do
    FileUtils.rm_rf @root_dir if File.exist?(@root_dir)
  end

  describe "module finder" do

    it "should find valid modules directory from root" do
      build_directory_structure "site/modules", "dist/modules", "random/nothing"
      modules = Locater.find_modules(@root_dir)
      modules.size.should == 2
    end

    it "should raise an exception if no module directories are found" do
      build_directory_structure "foo/bar", "random/nothing"
      lambda { Locater.find_modules(@root_dir) }.should raise_exception
    end

    it "should find only a single modules directory" do
      build_directory_structure "foo/bar", "blah", "site/modules", "dist/"
      modules = Locater.find_modules(@root_dir)
      modules.size.should == 1
    end
  end

  describe "site manifest finder" do

    it "should find a valid manifest directory" do
      build_directory_structure "manifests", "site/modules", "foo"
      add_files "manifests", "site.pp"
      Locater.find_site_manifest(@root_dir).should end_with("manifests")
    end

    it "should raise an exception if no site.pp file is found" do
      lambda { Locater.find_site_manifest(@root_dir) }.should raise_exception
    end
  end

  describe "librarian finder" do
    it "should find the puppet librarian directory in default location" do
      build_directory_structure "dist", "site/modules", "manifests"
      add_files "dist", "Puppetfile"
      Locater.find_librarian(@root_dir).should end_with("dist")
    end

    it "should find the puppet librarian directory in non-standard location" do
      build_directory_structure "foo/bar/blah", "test/bar", "test/blah"
      add_files "test/bar", "Puppetfile"
      Locater.find_librarian(@root_dir).should end_with("test/bar")
    end

    it "should return nil if no librarian directory found" do
      Locater.find_librarian(@root_dir).should == nil
    end
  end

  describe "test manifest finder" do

    it "should find an array of tests from the directory" do
      build_directory_structure "tests"
      add_files "tests", "init.pp", "test2.pp", "and_another_test.pp"
      test_manifests = Locater.find_test_manifests(@root_dir)
      test_manifests.should be_kind_of(Array)
      test_manifests.size.should == 3
    end

    it "should raise an exception if no valid tests are found" do
      build_directory_structure "tests"
      lambda { Locater.find_test_manifests(@root_dir) }.should raise_exception
    end
  end
end
