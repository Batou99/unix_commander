require 'spec_helper'

describe "Runner local" do
  before do
    @command = UnixCommander::Command.new("uname")
  end

  it "can access out after run command" do
    UnixCommander::Runner.new(@command).run.out.should == %x[uname]
  end

  it "can access err after run command with no errors" do
    UnixCommander::Runner.new(@command).run.err.should == ""
  end
  
  it "can access err after run command with errors" do
    @command = UnixCommander::Command.new("cat /etc/shadow")
    UnixCommander::Runner.new(@command).run.err.should_not == ""
  end

  it "can access out and err after run command with errors" do
    @command = UnixCommander::Command.new("grep abc /etc/*")
    UnixCommander::Runner.new(@command).run.err.should_not == ""
    UnixCommander::Runner.new(@command).run.out.should == %x[grep abc /etc/* 2> /dev/null]
  end
  
  it "should have empty data before run" do
    UnixCommander::Runner.new(@command).out == ""
    UnixCommander::Runner.new(@command).err == ""
  end

  it "can access out and err with an array" do
    @command = UnixCommander::Command.new("grep abc /etc/*")
    out_err = UnixCommander::Runner.new(@command).run.both
    out_err[0].should_not == ""
    out_err[1].should_not == ""
  end

  it "can read out twice" do
    runner = @command.run 
    runner.out.should == %x[uname]
    runner.out.should == %x[uname]
  end
  
  it "can read err twice" do
    @command = UnixCommander::Command.new("grep abc /etc/*")
    runner = @command.run 
    runner.out.should_not == ""
    runner.out.should_not == ""
  end
end

describe "Runner ssh" do
  before do
    @command = UnixCommander::Command.new("uname")
  end

  it "can access out after run command" do
    UnixCommander::Runner.new(@command).run_ssh('dev','dev').out.should == %x[uname]
  end

  it "can access err after run command with no errors" do
    UnixCommander::Runner.new(@command).run_ssh('dev','dev').err.should == ""
  end
  
  it "can access err after run command with errors" do
    @command = UnixCommander::Command.new("cat /etc/shadow")
    UnixCommander::Runner.new(@command).run_ssh('dev','dev').err.should_not == ""
  end

  it "can access out and err after run command with errors" do
    @command = UnixCommander::Command.new("grep abc /etc/*")
    UnixCommander::Runner.new(@command).run_ssh('dev','dev').err.should_not == ""
    UnixCommander::Runner.new(@command).run_ssh('dev','dev').out.should == %x[grep abc /etc/* 2> /dev/null]
  end
  
  it "can access out and err with an array" do
    @command = UnixCommander::Command.new("grep abc /etc/*")
    out_err = UnixCommander::Runner.new(@command).run_ssh('dev','dev').both
    out_err[0].should_not == ""
    out_err[1].should_not == ""
  end
  
  it "can read out twice" do
    runner = @command.run_ssh('dev','dev')
    runner.out.should == %x[uname]
    runner.out.should == %x[uname]
  end
  
  it "can read err twice" do
    @command = UnixCommander::Command.new("grep abc /etc/*")
    runner = @command.run_ssh('dev','dev')
    runner.out.should_not == ""
    runner.out.should_not == ""
  end
end
