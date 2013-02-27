# rubies-fish

A multi-version Ruby manager for the `fish` shell.


## Features

Switches between Ruby versions by munging `PATH`, thus avoiding
wrapper-scripts ('shims') for great speed.

Utilizes `fish`'s 'universal' variables to switch versions in all
open shells.

Override chosen version by setting `RUBY_VERSION` or by having a
`.ruby-version` file in the current working directory.


## Using

Clone the repository somewhere nice, and add the following line to
your `config.fish`:

	. /path/to/rubies-fish/rubies.fish

Then use `rubies-select` to see all available versions, and
`rubies-select <version>` to select a Ruby.

Run `rubies-rehash` after installing new Rubies (or relaunch your
shell)


## Installing Rubies

`rubies-fish` does not support installing Ruby. I suggest using
[ruby-build](https://github.com/sstephenson/ruby-build).

`rubies-fish` looks in `~/.rubies` by default, but you can change
the directory by setting the universal variable `rubies-directory`
to something else - eg. add the following line to your `config.fish`
to share Rubies with `rbenv`:

	set -U rubies-directory ~/.rbenv/versions
