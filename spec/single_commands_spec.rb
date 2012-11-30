require 'pry'
require './lib/unix_commander'

describe "Commands without chaining" do
  before do
    @command = UnixCommander::Command.new
  end

  it "should run commands with no args" do
    version = %x[uname]
    @command.uname.run.should == version
  end

  it "should run commands with one arg" do
    long_version = %x[uname -a]
    @command.uname("-a").run.should == long_version
  end

end

describe "Commands with chaining" do
  before do
    @command = UnixCommander::Command.new
  end

  it "can chain 2 commands" do
    uname_cut = %x[uname -a | cut -d'#' -f1]
    @command.uname("-a").cut("-d'#' -f1").run.should == uname_cut
  end

  it "can chain 3 commands" do
    cpuinfo = %x[ cat /proc/cpuinfo | awk '{ print $1 }' | head -n1]
    @command.cat("/proc/cpuinfo").awk("'{ print $1 }'").head("-n1").run.should == cpuinfo
  end
end

describe "Run via ssh" do
  before do
    @command = UnixCommander::Command.new
  end
  
  it "can chain 2 commands" do
    uname_cut = %x[uname -a | cut -d'#' -f1]
    @command.uname("-a").cut("-d'#' -f1").run_ssh('dev','dev').should == uname_cut
  end
end
