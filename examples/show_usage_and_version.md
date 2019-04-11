# libCLImate.Ruby Example - **show_usage_and_version**

## Summary

Simple example supporting ```--help``` and ```--version```.

## Source

```ruby
#!/usr/bin/env ruby

# examples/show_usage_and_version.rb

# requires

require 'libclimate'

# Specify specifications, parse, and checking standard flags

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
Illustrates use of libCLImate.Ruby's automatic support for '--help' and '--version'

USAGE: show_usage_and_version.rb [ ... flags and options ... ]

flags/options:

	--help
		shows this help and terminates

	--version
		shows version and terminates
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

