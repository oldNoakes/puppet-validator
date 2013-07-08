require 'validator/static_analysis_report'

describe "validator static analysis report generator" do
  describe "consolidating results" do

    before(:each) do
      @reporter = Validator::StaticAnalysisReport.new("test")
    end

    it "should create a new hash with the count of each issue type" do
      test_data = { "/path/to/file.pp" =>
                    { :validate =>
                      { :error => [],
                        :warning => ["validate warning 1", "validate warning 2"]
                      },
                      :lint =>
                      { :error => ["lint error 1"],
                        :warning => ["lint warning 1"]
                      }
                    }
                  }

      consolidated, sort_order = @reporter.consolidate(test_data)

      consolidated.keys.count.should == 1
      consolidated["/path/to/file.pp"][:href].should == "./path/to/file.html"
      consolidated["/path/to/file.pp"][:validate_errors].should == 0
      consolidated["/path/to/file.pp"][:validate_warnings].should == 2
      consolidated["/path/to/file.pp"][:lint_errors].should == 1
      consolidated["/path/to/file.pp"][:lint_warnings].should == 1
      consolidated["/path/to/file.pp"][:score].should == 16
    end

    it "should sort results by overall score" do
      test_data = { "/path/to/file.pp" =>
                    { :validate =>
                      { :error => [],
                        :warning => ["validate warning 1", "validate warning 2"]
                      },
                      :lint =>
                      { :error => ["lint error 1"],
                        :warning => ["lint warning 1"]
                      }
                    },
                    "/path/to/another/file.pp" =>
                    { :validate =>
                      { :error => ["validate error 1"],
                        :warning => []
                      },
                      :lint =>
                      { :error => ["lint error 1", "lint error2"],
                        :warning => []
                      }
                    }
                  }

      consolidated, sort_order  = @reporter.consolidate test_data
      sort_order[0].should == "/path/to/another/file.pp"
    end
  end

  describe "score based color" do
    it "should select an RGB color based on the score" do
      reporter = Validator::StaticAnalysisReport.new("test")
      reporter.get_color(0).should == "00FA00"
      reporter.get_color(125).should == "7DFA00"
      reporter.get_color(250).should == "FAFA00"
      reporter.get_color(375).should == "FA7D00"
      reporter.get_color(500).should == "FA0000"
      reporter.get_color(800).should == "FA0000"
    end
  end
end
