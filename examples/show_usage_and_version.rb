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


