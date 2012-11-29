require 'pry'
require './lib/unix_commander'

describe "No params" do
  before do
    @command = UnixCommander::Command.new
  end

  it "should capture stdout and stderr" do
    today = %x[uname]
    @command.uname.should == today
  end

end
