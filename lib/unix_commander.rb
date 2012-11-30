require "unix_commander/version"
require 'pry'
require 'open3'
require 'net/ssh'

module UnixCommander

  class Command

    attr :cmd

    def initialize(_cmd = "")
      @cmd = _cmd
    end

    def method_missing(m, *args, &block)
      if cmd == ""
        Command.new("#{m} #{args.join(' ')}".strip)
      else
        Command.new("#{cmd} | #{m} #{args.join(' ')}".strip)
      end
    end

    def run
      @in, @out, @err = Open3.popen3("#{cmd}")
      @out.read
    end

    def run_ssh(_username, _password = "", _address = "127.0.0.1")
      stdout_data = ""
      Net::SSH.start(_address,_username,:password => _password) do |ssh|
        channel = ssh.open_channel do |ch|
          ch.exec(@cmd) do |ch,success|
            # "on_data" is called when the process writes something to stdout
            ch.on_data do |c, data|
              stdout_data += data
            end

            # "on_extended_data" is called when the process writes something to stderr
            ch.on_extended_data do |c, type, data|
              raise "Error on command: #{data}"
            end
          end
        end
      end
      # We have to strip the extra linefeed
      stdout_data
    end
  end
end
