require 'validator/exceptions'
require 'validator/compiler'

describe "Compiler" do
  describe "compile" do
    before (:each) do
      @common_options = {:location => File.join(File.dirname(__FILE__), "resources", "compiler"), :verbose => false}
    end

    it "should pass with a valid node definition" do
      compiler = Validator::Compiler.new({:filter => /valid_node/}.merge(@common_options))
      lambda { compiler.compile }.should_not raise_error
    end

    it "should fail due to duplicate types with same name" do
      compiler = Validator::Compiler.new({:filter => /dupes_type/}.merge(@common_options))
      lambda { compiler.compile }.should raise_error(Validator::CompilationFailure)
    end

    it "should fail due to an explicit failure condition" do
      compiler = Validator::Compiler.new({:filter => /fail_call/}.merge(@common_options))
      lambda { compiler.compile }.should raise_error(Validator::CompilationFailure)
    end

    it "should fail due to an missing dependency condition" do
      compiler = Validator::Compiler.new({:filter => /missing_dependency/}.merge(@common_options))
      lambda { compiler.compile }.should raise_error(Validator::CompilationFailure)
    end

    it "should fail due to a ciruclar dependency condition" do
      compiler = Validator::Compiler.new({:filter => /circular_dependency/}.merge(@common_options))
      lambda { compiler.compile }.should raise_error(Validator::CompilationFailure)
    end

    it "should fail if a template source does not exits" do
      compiler = Validator::Compiler.new({:filter => /no_template/}.merge(@common_options))
      lambda { compiler.compile }.should raise_error(Validator::CompilationFailure)
    end

    it "should fail if dynamic scope warning is raised", :broken => true do
      compiler = Validator::Compiler.new(@common_options.merge({:filter => /dynamic_scope/}))
      lambda { compiler.compile }.should raise_error(Validator::CompilationFailure)
    end
  end
end
