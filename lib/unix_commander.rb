require "unix_commander/version"
require 'pry'
require 'open3'
require 'net/ssh'

module UnixCommander

  # This class encapsulates the output of a command. It also has the logic to run a command locally or remotely
  class Runner

    # @return [Command]
    attr :command


    # Creates a new Runner
    # @param _command The command to be run by the runner
    def initialize(_command)
      @command = _command
    end

    # Return a string with the output of the command
    # If the command has not been run yet it returns an empty string
    # @return [String] *stdout* and *stderr* of the command (*stdout* \\n *stderr*)
    def to_s
      both.join("\n")
    end

    # Returns the output (stdout) of the command
    # If the command has not been run yet it returns an empty string
    # @return [String] *stdout* of the command
    def out
      return "" if @out==nil
      return @out if @out.class==String
      @out.read
    end

    # Returns the output (stderr) of the command
    # If the command has not been run yet it returns an empty string
    # @return [String] *stderr* of the command
    def err
      return "" if @err==nil
      return @err if @err.class==String
      @err.read
    end

    # Return a string with the output of the command
    # If the command has not been run yet it returns ["",""]
    # @return [Array] *stdout* and *stderr* of the command
    def both
      [out, err]
    end

    # Runs the stored command locally
    # @return [Runner] Returns itself
    def run
      @in, @out, @err = Open3.popen3("#{@command.cmd}")
      self
    end

    # Runs the stored command remotely
    # @param _username The ssh username to access the remote server
    # @param _password The ssh password to access the remote server
    # @param _address The ssh server address to access the remote server. It defaults to localhost.
    # @return [Runner] Returns itself
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

  # This class encapsulates a command that will run in a unix machine locally or remotely
  class Command

    # @return [String]
    attr :cmd

    # Creates a new command
    # @param [String] create a command with some unix code inside (defaults to "")
    def initialize(_cmd = "")
      @cmd = _cmd
    end
    # Shows the string representation of the command being run in unix
    # @return [String]
    def to_s
      cmd
    end

    # This is the main method of the library. Every unknown method you call on a Command object
    # is interpreted as a unix command and its args are used as the args of the unix command.
    # When the command already has some unix command inside, it pipes them together (|)
    # @param [String] m name of the unix command you want to execute
    # @param [Array] *args args for the aforementioned command
    # @return [Command] new command with internal unix commands piped together
    def method_missing(m, *args, &block)
      if cmd == ""
        Command.new("#{m} #{args.join(' ')}".strip)
      else
        Command.new("#{cmd} | #{m} #{args.join(' ')}".strip)
      end
    end

    # Redirects *stdout* to someplace (Using >). By default it uses destructive redirection.
    # @param [String] place to redirect the output (e.g. /dev/null)
    # @param [true,false] append if true uses append redirection (>>) it defaults to false.
    # @return [Command] New command with *stdout* redirected to _str
    def out_to(_str,_append=false)
      if cmd == ""
        raise ArgumentError, "Cannot redirect with an empty command"
      else
        _append ? Command.new("#{cmd} >> #{_str}") : Command.new("#{cmd} > #{_str}")
      end
    end

    # Redirects *stderr* to someplace (Using >). By default it uses destructive redirection.
    # @param [String] place to redirect the output (e.g. /dev/null)
    # @param [true,false] append if true uses append redirection (>>) it defaults to false.
    # @return [Command] New command with *stderr* redirected to _str
    def err_to(_str,_append=false)
      if cmd == ""
        raise ArgumentError, "Cannot redirect with an empty command"
      else
        _append ? Command.new("#{cmd} 2>> #{_str}") : Command.new("#{cmd} 2> #{_str}")
      end
    end

    # Redirects *stdout* and *stderr* to someplace (Using >). By default it uses destructive redirection.
    # @param [String] place to redirect the output (e.g. /dev/null)
    # @param [true,false] append if true uses append redirection (>>) it defaults to false.
    # @return [Command] New command with *stdout and stderr* redirected to _str
    def both_to(_str,_append=false)
      if cmd == ""
        raise ArgumentError, "Cannot redirect with an empty command"
      else
        _append ? Command.new("#{cmd} >> #{_str} 2>&1") : Command.new("#{cmd} > #{_str} 2>&1")
      end
    end

    # Run the Command locally. The output is encapsulated in a Runner object
    # @return [Runner] runner object with the output inside
    def run
      Runner.new(self).run
    end

    # Run the Command remotely via ssh. The output is encapsulated in a Runner object
    # @param _username The ssh username to access the remote server
    # @param _password The ssh password to access the remote server
    # @param _address The ssh server address to access the remote server. It defaults to localhost.
    # @return [Runner] runner object with the output inside
    def run_ssh(_username, _password = "", _address = "127.0.0.1")
      Runner.new(self).run_ssh(_username,_password,_address)
    end
  end
      
end
