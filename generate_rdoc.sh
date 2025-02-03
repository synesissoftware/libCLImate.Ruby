#!/bin/bash

# ##########################################################################
# File:     generate_rdoc.sh
#
# Purpose:  Generates documentation
#
# Created:  11th June 2016
# Updated:  3rd February 2025
#
# ##########################################################################

rm -rfd doc
rdoc \
	-x build_gem.sh \
	-x generate_rdoc.sh \
	-x run_all_unit_tests.sh \
	-x libCLImate.gemspec \
	\
	-x doc/ \
	-x gems/ \
	-x old-gems/ \
	-x test/scratch/ \
	\
	-x ts_all.rb \
	-x tc_.*\.rb \
	\
	$*


# ############################## end of file ############################# #

