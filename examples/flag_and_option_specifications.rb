#! /usr/bin/env ruby

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

	cl.version = [ 0, 1, 0 ]

	cl.info_lines =  [

		'libCLImate.Ruby examples',
		:version,
		"Illustrates use of libCLImate.Ruby's specification of flags, options, and specifications",
		'',
	]

	cl.constrain_values = 1..2
	cl.usage_values = "<dir-1> [ <dir-2> ]"
	cl.value_names = [

		"first directory",
		"second directory",
	]
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

