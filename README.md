# UnixCommander

This is a gem used to run unix commands ruby style.
Normally to run a command we have to do something like:

```
%x[cat file | tail -n10 | grep 'something']
```

The goal is to be able to do it with a more rubyesque way.

## Installation

Add this line to your application's Gemfile:

    gem 'unix_commander'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install unix_commander

## Usage

With this gem you will be able to run unix commands this way:

```
require 'unix_commander'

comm = UnixCommander::Command.new
comm.cat("file").tail("-n10").grep("'something'").run
```

You can use redirection too
```
require 'unix_commander'

comm = UnixCommander::Command.new
comm.cat("file").tail("-n10").grep("'something'").out_to("my_file").err_to("/dev/null")
```

>>>>>>> development
You don't have to run the commands right away, we can create a command and run it whe we see fit:

```
require 'unix_commander'

comm = UnixCommander::Command.new
comm = comm.cat("file").tail("-n10").grep("'something'")

...

comm.run
```

Also you can run commands remotely using ssh using **run_ssh** instead of **run**.
(Syntax: **run_shh(username, password,server)** or **run_ssh(username,password)** to connect to localhost)

```
require 'unix_commander'

comm = UnixCommander::Command.new
comm.cat("file").tail("-n10").grep("'something'").run_ssh("Batou99","secret","remote_server")
```

After running a command you can access it output using **out**, **err** or **both**
```
require 'unix_commander'

comm = UnixCommander::Command.new
comm.cat("file").tail("-n10").grep("'something'").run_ssh("Batou99","secret","remote_server").out
# Or
comm.cat("file").tail("-n10").grep("'something'").run_ssh("Batou99","secret","remote_server").err
# Or
comm.cat("file").tail("-n10").grep("'something'").run_ssh("Batou99","secret","remote_server").both
```
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
