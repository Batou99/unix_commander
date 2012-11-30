require "unix_commander/version"
require 'pry'
require 'open3'

module UnixCommander

  class Command

    attr :cmd

    def initialize(_cmd = ->() { "" })
      @cmd = _cmd
    end

    def method_missing(m, *args, &block)
      if @cmd.call == ""
        Command.new(->() { "#{m} #{args.join(' ')}".strip })
      else
        Command.new(->() { "#{@cmd.call} | #{m} #{args.join(' ')}".strip })
      end
    end

    def run
      @in, @out, @err = Open3.popen3("#{@cmd.call}")
      @out.read
    end
  end
  # Your code goes here...
end
