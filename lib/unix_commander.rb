require "unix_commander/version"
require 'pry'
require 'open3'
require 'net/ssh'

module UnixCommander

  class Runner

    attr :command

    def initialize(_command)
      @command = _command
    end

    def to_s
      both.join("\n")
    end

    def out
      return "" if @out==nil
      return @out if @out.class==String
      @out.read
    end

    def err
      return "" if @err==nil
      return @err if @err.class==String
      @err.read
    end

    def both
      [out, err]
    end

    def run
      @in, @out, @err = Open3.popen3("#{@command.cmd}")
      self
    end

    def run_ssh(_username, _password = "", _address = "127.0.0.1")
      stdout_data = ""
      stderr_data = ""
      Net::SSH.start(_address,_username,:password => _password) do |ssh|
        channel = ssh.open_channel do |ch|
          ch.exec(@command.cmd) do |ch,success|
            # "on_data" is called when the process writes something to stdout
            ch.on_data do |c, data|
              stdout_data += data
            end

            # "on_extended_data" is called when the process writes something to stderr
            ch.on_extended_data do |c, type, data|
              stderr_data += data
            end
          end
        end
      end
      @out = stdout_data
      @err = stderr_data
      self
    end
  end


  class Command

    attr :cmd

    def initialize(_cmd = "")
      @cmd = _cmd
    end

    def to_s
      cmd
    end

    def method_missing(m, *args, &block)
      if cmd == ""
        Command.new("#{m} #{args.join(' ')}".strip)
      else
        Command.new("#{cmd} | #{m} #{args.join(' ')}".strip)
      end
    end

    def out_to(_str,_append=false)
      if cmd == ""
        raise ArgumentError, "Cannot redirect with an empty command"
      else
        _append ? Command.new("#{cmd} >> #{_str}") : Command.new("#{cmd} > #{_str}")
      end
    end

    def err_to(_str,_append=false)
      if cmd == ""
        raise ArgumentError, "Cannot redirect with an empty command"
      else
        _append ? Command.new("#{cmd} 2>> #{_str}") : Command.new("#{cmd} 2> #{_str}")
      end
    end

    def both_to(_str,_append=false)
      if cmd == ""
        raise ArgumentError, "Cannot redirect with an empty command"
      else
        _append ? Command.new("#{cmd} >> #{_str} 2>&1") : Command.new("#{cmd} > #{_str} 2>&1")
      end
    end

    def run
      Runner.new(self).run
    end

    def run_ssh(_username, _password = "", _address = "127.0.0.1")
      Runner.new(self).run_ssh(_username,_password,_address)
    end
  end
      
end
