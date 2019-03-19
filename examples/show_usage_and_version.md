# libCLImate.Ruby Example - **show_usage_and_version**

## Summary

Simple example supporting ```--help``` and ```--version```.

## Source

```ruby
#!/usr/bin/env ruby

# examples/flag_and_option_aliases.rb

# requires

require 'libclimate'

# Specify aliases, parse, and checking standard flags

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
		"Illustrates use of libCLImate.Ruby's specification of flags, options, and aliases",
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
    ruby examples/show_usage_and_version.rb
```

or (in a Unix shell):

```
    ./examples/show_usage_and_version.rb
```

it gives the output:

```
no flags specified
```

### Show usage

If executed with the arguments

```
    ruby examples/show_usage_and_version.rb --help
```

it gives the output:

```
libCLImate.Ruby examples
show_usage_and_version.rb 0.0.1
Illustrates use of libCLImate.Ruby's show_usage() and show_version() methods

USAGE: show_usage_and_version.rb [ ... flags and options ... ]

flags/options:

	--help
		Shows usage and terminates

	--version
		Shows version and terminates
```

### Show version

If executed with the arguments

```
    ruby examples/show_usage_and_version.rb --version
```

it gives the output:

```
show_usage_and_version.rb 0.0.1
```

### Unknown option

If executed with the arguments

```
    ruby examples/show_usage_and_version.rb --unknown=value
```

it gives the output (on the standard error stream):

```
show_usage_and_version.rb: unrecognised flag/option: --unknown=value
```

with an exit code of 1

