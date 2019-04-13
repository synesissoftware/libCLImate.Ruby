# libCLImate.Ruby Example - **flag_and_option_specifications**

## Summary

Example illustrating various kinds of *flag* and *option* specifications, including the combination of short-names.

## Source

```ruby
#!/usr/bin/env ruby

# examples/flag_and_option_specifications.rb

# requires

require 'libclimate'

# Specify specifications, parse, and checking standard flags

options = {}
climate = LibCLImate::Climate.new do |cl|

	cl.add_flag('--debug', alias: '-d', help: 'runs in Debug mode') do

		options[:debug] = true
	end
	cl.add_option('--verbosity', alias: '-v', help: 'specifies the verbosity', values: [ 'terse', 'quiet', 'silent', 'chatty' ]) do |o, a|

		options[:verbosity] = o.value
	end
	cl.add_alias('--verbosity=chatty', '-c')

	cl.version = [ 0, 0, 1 ]

	cl.info_lines =  [

		'libCLImate.Ruby examples',
		:version,
		"Illustrates use of libCLImate.Ruby's specification of flags, options, and specifications",
		'',
	]
end

r = climate.run ARGV



# Program-specific processing of flags/options

if options[:verbosity]

	$stdout.puts "verbosity is specified as: #{options[:verbosity]}"
end

if options[:debug]

	$stdout.puts 'Debug mode is specified'
end
```

## Usage

### No arguments

If executed with no arguments

```
    ruby examples/flag_and_option_specifications.rb
```

or (in a Unix shell):

```
    ./examples/flag_and_option_specifications.rb
```

it gives the output:

```
```

### Show usage

If executed with the arguments

```
    ruby examples/flag_and_option_specifications.rb --help
```

it gives the output:

```
libCLImate.Ruby examples
flag_and_option_specifications.rb 0.0.1
Illustrates use of libCLImate.Ruby's specification of flags, options, and specifications

USAGE: flag_and_option_specifications.rb [ ... flags and options ... ]

flags/options:

	-d
	--debug
		runs in Debug mode

	-c --verbosity=chatty
	-v <value>
	--verbosity=<value>
		specifies the verbosity
		where <value> one of:
			terse
			quiet
			silent
			chatty

	--help
		Shows usage and terminates

	--version
		Shows version and terminates
```

### Specify flags and options in long-form

If executed with the arguments

```
    ruby examples/flag_and_option_specifications.rb --debug --verbosity=silent
```

it gives the output:

```
verbosity is specified as: silent
Debug mode is specified
```

### Specify flags and options in short-form

If executed with the arguments

```
    ruby examples/flag_and_option_specifications.rb -v silent -d
```

it gives the (same) output:

```
verbosity is specified as: silent
Debug mode is specified
```

### Specify flags and options in short-form, including an alias for an option-with-value

If executed with the arguments

```
    ruby examples/flag_and_option_specifications.rb -c -d
```

it gives the output:

```
verbosity is specified as: chatty
Debug mode is specified
```

### Specify flags and options with combined short-form

If executed with the arguments

```
    ruby examples/flag_and_option_specifications.rb -dc
```

it gives the (same) output:

```
verbosity is specified as: chatty
Debug mode is specified
```

