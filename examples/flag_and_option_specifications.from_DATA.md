# libCLImate.Ruby Example - **flag_and_option_specifications.from_DATA**

## Summary

Example illustrating various kinds of *flag* and *option* specifications, including the combination of short-names, loaded from the ``__END__``/``DATA`` section of the program file in **YAML** form.

## Source

```ruby
#! /usr/bin/env ruby

# examples/flag_and_option_specifications.from_DATA.rb


# requires

require 'libclimate'


# Specify aliases, parse, and checking standard flags

options = {}
climate = LibCLImate::Climate.load DATA do |cl|

	cl.on_flag('--debug') { options[:debug] = true }

	cl.on_option('--verbosity') { |o, a| options[:verbosity] = o.value }
end

r = climate.parse_and_verify ARGV


# Program-specific processing of flags/options

if options[:verbosity]

	$stdout.puts "verbosity is specified as: #{options[:verbosity]}"
end

if options[:debug]

	$stdout.puts 'Debug mode is specified'
end


# some notional output

$stdout.puts "processing in '#{r.values[0]}'" + (r.values.size > 1 ? " and '#{r.values[1]}'" : '')


__END__
---
libclimate:
  clasp:
    specifications:
    - flag:
        name:  --debug
        alias:  -d
        help:  runs in Debug mode
        required:  false
    - option:
        name:  --verbosity
        alias: -v
        help:  specifies the verbosity
        values:
        - silent
        - quiet
        - terse
        - chatty
        - verbose
    - alias:
        resolved:  --verbosity=chatty
        aliases:
        - --chatty
        - -c
  constrain_values: !ruby/range 1..2
  exit_on_missing: true
  flags_and_options: "[... flags/options ...]"
  usage_values: "<dir-1> [ <dir-2> ]"
  value_names:
  - first directory
  - second directory
  info_lines:
  - libCLImate.Ruby examples
  - :version
  - Illustrates use of libCLImate.Ruby's specification of flags, options, and aliases, from DATA
  -
  version:
  - 0
  - 2
  - "0"
```

## Usage

NOTE: in order to demonstrate fully the utility of the *loading-from-source-file-YAML* facility, I've added a constraint for 1-2 values - notionally directories - 

### No arguments

If executed with no arguments

```
    ruby examples/flag_and_option_specifications.from_DATA.rb
```

or (in a Unix shell):

```
    ./examples/flag_and_option_specifications.from_DATA.rb
```

it gives the output (with an exit code of **1**):

```
flag_and_option_specifications.from_DATA(.rb): first directory not specified; use --help for usage
```


### Show usage

If executed with the arguments

```
    ruby examples/flag_and_option_specifications.from_DATA.rb --help
```

it gives the output:

```
libCLImate.Ruby examples
flag_and_option_specifications.from_DATA(.rb) 0.2.0
Illustrates use of libCLImate.Ruby's specification of flags, options, and aliases, from DATA

USAGE: flag_and_option_specifications.from_DATA(.rb) [... flags/options ...] <dir-1> [ <dir-2> ]

flags/options:

	--help
		shows this help and terminates

	--version
		shows version and terminates

	-d
	--debug
		runs in Debug mode

	--chatty --verbosity=chatty
	-c --verbosity=chatty
	--verbosity=<value>
		specifies the verbosity
		where <value> one of:
			silent
			quiet
			terse
			chatty
			verbose

```

### Specify flags and options in long-form

If executed with the arguments

```
    ruby examples/flag_and_option_specifications.from_DATA.rb dir-1 dir-2 --debug --verbosity=silent
```

it gives the output:

```
verbosity is specified as: silent
Debug mode is specified
processing in 'dir-1' and 'dir-2'
```

### Specify flags and options in short-form

If executed with the arguments

```
    ruby examples/flag_and_option_specifications.from_DATA.rb dir-1 dir-2 -v silent -d
```

it gives the (same) output:

```
verbosity is specified as: silent
Debug mode is specified
processing in 'dir-1' and 'dir-2'
```

### Specify flags and options in short-form, including an alias for an option-with-value

If executed with the arguments

```
    ruby examples/flag_and_option_specifications.from_DATA.rb dir-1 dir-2 -c -d
```

it gives the output:

```
verbosity is specified as: chatty
Debug mode is specified
processing in 'dir-1' and 'dir-2'
```

### Specify flags and options with combined short-form

If executed with the arguments

```
    ruby examples/flag_and_option_specifications.from_DATA.rb dir-1 dir-2 -dc
```

it gives the (same) output:

```
verbosity is specified as: chatty
Debug mode is specified
processing in 'dir-1' and 'dir-2'
```
