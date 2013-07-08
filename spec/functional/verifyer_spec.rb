require 'validator/parser'

describe "Verifyer" do
  describe "verify" do
    before (:each) do
      @verify_resources = File.join(File.dirname(__FILE__), "resources", "verifyer")
    end

    it "should find a syntax error" do
      file = File.join(@verify_resources, "syntax-error.pp")
      results = Validator::Parser.new(file).run
      results[file][:validate][:error].size.should == 1
      results[file][:validate][:error].to_s.should =~ /Syntax error/
    end

    it "should find a unrecognised character warning" do
      file = File.join(@verify_resources, "character-warning.pp")
      results = Validator::Parser.new(file).run
      results[file][:validate][:warning].size.should == 1
      results[file][:validate][:warning].to_s.should =~ /Unrecognised escape sequence/
    end
  end
end
