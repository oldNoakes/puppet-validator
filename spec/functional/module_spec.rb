require 'validator/module'
require 'common/locater'
describe "Module validator" do
  describe "evaluate" do
    it "should return an error if the catalog for a specific test cannot be compiled" do
      validator = Validator::Module.new("nocompile")
      module_location = File.join(File.dirname(__FILE__), "resources")
      results = validator.run_tests(module_location)
      results.size.should == 2
      results["no_compile.pp"].should =~ /FAILURE/
    end

    it "should return a success message if all tests are compiled" do
      validator = Validator::Module.new("working")
      module_location = File.join(File.dirname(__FILE__), "resources")
      results = validator.run_tests(module_location)
      results.size.should == 1
      results.values.first.should =~ /SUCCESS/
    end
  end
end
