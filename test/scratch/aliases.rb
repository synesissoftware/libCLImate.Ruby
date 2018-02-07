#!/usr/bin/env ruby

#############################################################################
# File:         test/scratch/aliases.rb
#
# Purpose:      Demonstrates use of aliases in options and flags
#
# Created:      7th February 2018
# Updated:      7th February 2018
#
# Author:       Matthew Wilson
#
# Copyright:    <<TBD>>
#
#############################################################################

$:.unshift File.join(File.dirname(__FILE__), '../..', 'lib')


require 'libclimate'

# ##########################################################
# constants

PROGRAM_VER_MAJOR               =   0
PROGRAM_VER_MINOR               =   1
PROGRAM_VER_REVISION            =   1
PROGRAM_VER_BUILD               =   1

# ##########################################################
# command-line parsing

options = {}

r = LibCLImate::Climate.new do |cl|

	cl.add_flag('--verbose', alias: '-v', help: 'specifies verbosity') { options[:verbose] = true }
	cl.add_alias('--verbose', '--V')

	cl.add_option('--logging-threshold', alias: '-l', help: 'specifies the logging threshold') { |o, a| options[:logging_threshold] = o.value }
	cl.add_alias('--logging-threshold=informational', '--I')

	cl.info_lines = [

		:version,
		'demonstrates use of aliases',
	]
end.run


# ##########################################################
# main

puts "logging-threshold: #{options[:logging_threshold]}"
puts "verbose: #{options[:verbose]}"

# ############################## end of file ############################# #


