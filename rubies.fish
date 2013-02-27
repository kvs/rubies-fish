# rubies-fish
#
# (c) Copyright 2013, Kenneth Vestergaard <kvs@binarysolutions.dk>.
#
# A Ruby version switcher for fish.
#
# Install Rubies, and switch with 'rubies-select'.
#
# Override global version with either a RUBY_VERSION
# environment variable, or a '.ruby-version' file.
#
# Find the latest version at https://github.com/kvs/rubies-fish


## VARIABLES

# `rubies_version` is the globally selected Ruby version
if not set -U -q rubies_version
	set -U rubies_version system
end

# `rubies_directory` is the place to look for installed rubies
if not set -U -q rubies_directory
	set -U rubies_directory ~/.rubies
end



## USER FUNCTIONS

function rubies-select -d "Show or set which Ruby version to use"
	if test -z $argv[1]
		echo "The following Ruby versions are available for use:"
		for rubyver in (ls $rubies_directory)
			if test $rubyver = $__rubies_active_version
				echo (set_color green)" . $rubyver (current, $__rubies_active_scope)"(set_color normal)
			else if test -x $rubies_directory/$rubyver/bin/ruby
				echo " . $rubyver"
			end
		end

		if test $__rubies_active_version = system
			echo (set_color green)" . system (current, $__rubies_active_scope)"(set_color normal)
		else
			echo " . system"
		end

		if set -q __rubies_active_invalid
			echo (set_color yellow)" . $__rubies_active_version (current, $__rubies_active_scope, invalid)"(set_color normal)
		end
	else
		# Select version from $argv

		switch $argv[1]
			case '-g'
				if __rubies-valid-version $argv[2]
					echo (set_color green)"* Switched global Ruby version to $argv."(set_color normal)
					set -U rubies_version $argv[2]
					if test $__rubies_active_scope != global
						echo (set_color yellow)"* NOTE: local override ($__rubies_active_scope) in effect."(set_color normal)
					end
				else
					echo (set_color red)"* Sorry, you didn't specify a known version."(set_color normal)
					return 1
				end
			case '*'
				if test $argv = global
					if set -q RUBY_VERSION
						set -e RUBY_VERSION
						echo (set_color green)"* Switched Ruby version for this shell back to global ($__rubies_active_version)."(set_color normal)
					else
						echo (set_color yellow)"* No local override in effect."(set_color normal)
					end
				else if __rubies-valid-version $argv
					set -g RUBY_VERSION $argv
					echo (set_color green)"* Switched Ruby version for this shell to $argv[1]."(set_color normal)
				else
					echo (set_color red)"* Sorry, you didn't specify a known version."(set_color normal)
					return 1
				end
		end
	end
end

function rubies-rehash -d "Rebuild list of valid Rubies"
	for candidate in (find $rubies_directory -maxdepth 1 -type d)
		if [ -x $candidate/bin/ruby ]
			set shortnames (basename $candidate) $shortnames
		end
	end

	complete -e -c rubies-select
	complete -c rubies-select -n '__fish_not_contain_opt -s g' -x -s l -d "Select shell-local Ruby version" -a "$shortnames system" -A
	complete -c rubies-select -n '__fish_not_contain_opt -s l -s g' -f -d "Select global Ruby version" -a "$shortnames system" -A
	complete -c rubies-select -n '__fish_not_contain_opt -s l' -f -s g -d "Switch back to global Ruby version" -A
end



## INTERNAL FUNCTIONS

# Determine active Ruby version for current shell/cwd, and
# update PATH to match.
function __rubies-update -v RUBY_VERSION -v rubies_version -v PWD
	if set -q __rubies_active_version
		set __prev_rubies_active_version $__rubies_active_version
	else
		set __prev_rubies_active_version nil
	end

	set -g __rubies_active_version $rubies_version
	set -g __rubies_active_scope   global
	set -e __rubies_active_invalid

	# Determine active Ruby version
	if not test -z $RUBY_VERSION
		set -g __rubies_active_version $RUBY_VERSION
		set -g __rubies_active_scope   RUBY_VERSION
	else if test -f .ruby-version
		set -g __rubies_active_version (cat .ruby-version)
		set -g __rubies_active_scope   .ruby-version
	end

	# Don't update PATH if invalid Ruby is selected
	if not __rubies-valid-version $__rubies_active_version
		set -g __rubies_active_invalid
		return
	end

	# Don't update PATH if nothing changed
	if test $__prev_rubies_active_version = $__rubies_active_version
		return
	end

	# Remove old PATH parts
	for i in (seq (count $PATH))
		switch $PATH[$i]
			case "$rubies_directory/*"
				set remove_paths $remove_paths $i
		end
	end
	if set -q remove_paths
		set -e PATH[$remove_paths]
	end

	# Add active Ruby to PATH
	if test $__rubies_active_version != system
		set -x PATH $rubies_directory/$__rubies_active_version/bin $PATH
	end
end

# Check if a given Ruby version is installed and executable
function __rubies-valid-version
	if test $argv = system
		return 0
	else if test -x $rubies_directory/$argv/bin/ruby
		return 0
	end

	return 1
end

# Wrapper to ensure 'rubies-rehash' is run after installing a new Ruby with ruby-build
function ruby-build
	command ruby-build $argv
	rubies-rehash
end

# Fire it up
rubies-rehash
__rubies-update
