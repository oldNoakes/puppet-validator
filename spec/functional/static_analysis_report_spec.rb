require 'validator/static_analysis_report'

describe "Validator Static Analysis Report Generator" do
  before(:each) do
    @template_root = File.expand_path(File.join(File.dirname(__FILE__), "resources", "report"))
    @report_creator = Validator::StaticAnalysisReport.new(@template_root)
  end
  after(:each) do
    Dir.glob("#{@template_root}/*.html").each { |file| File.delete(file) }
  end

  it "should generate a test report from a bound object" do
    binding = OpenStruct.new(:test_name => "test report", :test_value1 => "value 1", :test_hash => ["hash value 1", "hash value 2", 3])
    @report_creator.generate_html(File.join(@template_root, "test_report.erb"), binding, "test_report.html")

    contents = File.open(File.join(@template_root, "test_report.html")).read
    contents.should include "hash value 1"
  end
end
