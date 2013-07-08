require 'common/locater'
require 'validator/compiler'

describe "Validator compiler" do
  describe "compiling" do
    it "should not try and compile if no nodes found" do
      compiler = Validator::Compiler.new
      Locater.should_receive(:find_site_manifest)
      Locater.should_receive(:find_modules)
      compiler.should_receive(:setup_compile)
      compiler.should_receive(:collect_puppet_nodes).and_return([])

      lambda { compiler.compile }.should raise_exception("No nodes found to compile")
    end
  end
  describe "splitting nodes into subgroups" do
    before(:each) do
      @compiler = Validator::Compiler.new
    end

    it "should split nodes array by number of cpus on the box" do
      @compiler.should_receive(:read_override_file).with("chunks").and_return(nil)
      @compiler.should_receive(:number_cpus).and_return(4)

      original_array = (0..51).to_a
      split_arrays = @compiler.split_nodes(original_array)

      split_arrays.size.should == 4
    end

    it "should split nodes array by value in file if given" do
      @compiler.should_receive(:read_override_file).with("chunks").and_return(2)
      @compiler.should_not_receive(:number_cpus)

      original_array = (0..51).to_a
      split_arrays = @compiler.split_nodes(original_array)

      split_arrays.size.should == 2
    end
  end

  describe "reading compile override file" do
    it "should return nil if the file does not exist" do
      compiler = Validator::Compiler.new
      compiler.read_override_file("chunks").should == nil
    end

    it "should return nil if the key does not exist" do
      compiler = Validator::Compiler.new({:location => File.join(File.dirname(__FILE__), "..", "resources")})
      compiler.read_override_file("foo").should == nil
    end

    it "should return key value" do
      compiler = Validator::Compiler.new({:location => File.join(File.dirname(__FILE__), "..", "resources")})
      compiler.read_override_file("chunks").should == 4
    end
  end
end
