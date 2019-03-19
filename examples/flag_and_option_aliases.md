# libCLImate.Ruby Example - **show_usage_and_version**

## Summary

Example illustrating various kinds of *flag* and *option* aliases, including the combination of short-names.

## Source

```ruby
#!/usr/bin/env ruby

# examples/show_usage_and_version.rb

# requires

require 'libclimate'

# Specify aliases, parse, and checking standard flags

climate = LibCLImate::Climate.new do |cl|

	cl.version = [ 0, 0, 1 ]

	cl.info_lines =  [

		'libCLImate.Ruby examples',
		:version,
		"Illustrates use of libCLImate.Ruby's automatic support for '--help' and '--version'",
		'',
	]
end

climate.run ARGV



$stdout.puts 'no flags specified'
```

## Usage

### No arguments

If executed with no arguments

```
    ruby examples/flag_and_option_aliases.rb
```

or (in a Unix shell):

```
    ./examples/flag_and_option_aliases.rb
```

it gives the output:

```
```

### Show usage

If executed with the arguments

```
    ruby examples/flag_and_option_aliases.rb --help
```

it gives the output:

```
libCLImate.Ruby examples
flag_and_option_aliases.rb 0.0.1
Illustrates use of libCLImate.Ruby's automatic support for '--help' and '--version'

USAGE: flag_and_option_aliases.rb [ ... flags and options ... ]

flags/options:

	--help
		Shows usage and terminates

	--version
		Shows version and terminates
```

### Specify flags and options in long-form

If executed with the arguments

```
    ruby examples/flag_and_option_aliases.rb --debug --verbosity=silent
```

it gives the output:

```
verbosity is specified as: silent
Debug mode is specified
```

### Specify flags and options in short-form

If executed with the arguments

```
    ruby examples/flag_and_option_aliases.rb -v silent -d
```

it gives the (same) output:

```
verbosity is specified as: silent
Debug mode is specified
```

### Specify flags and options in short-form, including an alias for an option-with-value

If executed with the arguments

```
    ruby examples/flag_and_option_aliases.rb -c -d
```

it gives the output:

```
verbosity is specified as: chatty
Debug mode is specified
```

### Specify flags and options with combined short-form

If executed with the arguments

```
    ruby examples/flag_and_option_aliases.rb -dc
```

it gives the (same) output:

```
verbosity is specified as: chatty
Debug mode is specified
```

