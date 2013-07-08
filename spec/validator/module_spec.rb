require 'validator/module'

describe "Puppet module validator" do
  before(:each) do
    @validator = Validator::Module.new("test-technology")
    @validator.should_receive(:setup_modulepath).once
    Locater.should_receive(:find_test_manifests).and_return(["test.pp", "test2.pp"])
    Locater.should_receive(:find_modules).and_return(["modules/test-technology"])
    @validator.should_receive(:setup_module).twice
    @validator.should_receive(:cleanup_modulepath).once
  end

  it "should return an array of messages" do
    @validator.should_receive(:compile_catalog).with("test.pp", ".")
    @validator.should_receive(:compile_catalog).with("test2.pp", ".").and_raise "foobar"
    results = @validator.test_module

    results["test.pp"].should =~ /SUCCESS/
    results["test2.pp"].should =~ /FAILURE/
  end
end
