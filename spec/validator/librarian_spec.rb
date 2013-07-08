require 'common/locater'
require 'validator/librarian'

describe "Validator librarian executor" do
  before(:each) do
    @locater_root = File.join(File.dirname(__FILE__), "..")
  end
  it "should do nothing if no Puppetfile is located" do
    Locater.should_receive(:find_librarian).with(".").and_return(nil)

    librarian = Validator::Librarian.new
    librarian.should_not_receive(:verify_puppet_librarian)
    Dir.should_not_receive(:chdir)

    librarian.run
  end

  it "should fail if Puppetfile is found but puppet librarian is not installed" do
    librarian = Validator::Librarian.new(@locater_root)
    librarian.should_receive(:run_command).with("/usr/bin/which librarian-puppet").and_return(false)

    lambda{ librarian.run }.should raise_exception
  end

  it "should run puppet librarian in the Puppetfile directory" do
    librarian = Validator::Librarian.new(@locater_root)
    librarian.should_receive(:run_command).with("/usr/bin/which librarian-puppet").and_return(true)
    librarian.should_receive(:run_command).with("librarian-puppet install").and_return(true)

    librarian.run
  end

  it "should fail if puppet librarian fails" do
    librarian = Validator::Librarian.new(@locater_root)
    librarian.should_receive(:run_command).with("/usr/bin/which librarian-puppet").and_return(true)
    librarian.should_receive(:run_command).with("librarian-puppet install").and_return(false)

    lambda{ librarian.run }.should raise_exception
  end

  it "should run puppet librarian with clean option on if given" do
    librarian = Validator::Librarian.new(@locater_root, true)
    librarian.should_receive(:run_command).with("/usr/bin/which librarian-puppet").and_return(true)
    librarian.should_receive(:run_command).with("librarian-puppet install --clean").and_return(true)

    librarian.run
  end
end
