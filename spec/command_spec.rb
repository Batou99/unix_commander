require 'pry'
require './lib/unix_commander'

describe "Commands without chaining" do
  before do
    @command = UnixCommander::Command.new
  end

  it "should accept commands with no args" do
    version = %x[uname]
    @command.uname.to_s.should == "uname"
  end

  it "should accept commands with one arg" do
    @command.uname("-a").to_s.should == "uname -a"
  end

end

describe "Commands with chaining" do
  before do
    @command = UnixCommander::Command.new
  end

  it "can chain 2 commands" do
    @command.uname("-a").cut("-d'#' -f1").to_s.should == "uname -a | cut -d'#' -f1"
  end

  it "can chain 3 commands" do
    @command.cat("/proc/cpuinfo").awk("'{ print $1 }'").head("-n1").to_s.should == "cat /proc/cpuinfo | awk '{ print $1 }' | head -n1"
  end
end

describe "Running" do
  before do
    @command = UnixCommander::Command.new.uname
  end

  it "should call a runner" do
    UnixCommander::Runner.any_instance.should_receive(:run).and_return(%x[uname -a])
    @command.run.should == %x[uname -a]
  end

  it "should call a runner over ssh" do
    UnixCommander::Runner.any_instance.should_receive(:run_ssh).with('dev','devpass','localhost').and_return(%x[uname -a])
    @command.run_ssh('dev','devpass','localhost').should == %x[uname -a]
  end
end

describe "Redirection" do
  before do
    @command = UnixCommander::Command.new.uname("-a").cut("-d' ' -f1")
  end
  
  it "should translate to_s correctly" do
    @command.to_s.should == "uname -a | cut -d' ' -f1" 
  end

  it "should redirect stdout" do
    @command.out_to('/dev/null').to_s.should == "uname -a | cut -d' ' -f1 > /dev/null" 
  end

  it "should redirect stderr" do
    @command.err_to('/dev/null').to_s.should == "uname -a | cut -d' ' -f1 2> /dev/null" 
  end

  it "should redirect both" do
    @command.both_to('/dev/null').to_s.should == "uname -a | cut -d' ' -f1 > /dev/null 2>&1" 
  end

  it "should append stdout" do
    @command.out_to('/dev/null',true).to_s.should == "uname -a | cut -d' ' -f1 >> /dev/null" 
  end

  it "should append stderr" do
    @command.err_to('/dev/null',true).to_s.should == "uname -a | cut -d' ' -f1 2>> /dev/null" 
  end

  it "should append both" do
    @command.both_to('/dev/null',true).to_s.should == "uname -a | cut -d' ' -f1 >> /dev/null 2>&1" 
  end
end

