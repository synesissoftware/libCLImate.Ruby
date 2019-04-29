#!/usr/bin/env ruby

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

