require "unix_commander/version"
require 'pry'
require 'open3'

module UnixCommander

  class Command

    attr :name
    attr :args
    attr :out
    attr :err
    attr :in

    def method_missing(m, *args, &block)
      @in, @out, @err = Open3.popen3(m.to_s)
      @out.read
    end
  end
  # Your code goes here...
end
