#!/usr/bin/env ruby

# examples/show_usage_and_version.rb

# requires

require 'libclimate'

# Specify specifications, parse, and checking standard flags

climate = LibCLImate::Climate.new do |cl|

	cl.version = [ 0, 1, 0 ]

	cl.info_lines =  [

		'libCLImate.Ruby examples',
		:version,
		"Illustrates use of libCLImate.Ruby's automatic support for '--help' and '--version'",
		'',
	]
end

climate.parse_and_verify ARGV



$stdout.puts 'no flags specified'


