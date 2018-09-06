#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), '../..', 'lib')


require 'libclimate'

require 'xqsr3/extensions/test/unit'
require 'test/unit'

require 'stringio'

class Test_Climate_values_constraints < Test::Unit::TestCase

	def test_constrain_with_no_constraint

		stdout	=	StringIO.new
		stderr	=	StringIO.new

		climate = LibCLImate::Climate.new do |cl|

			cl.exit_on_unknown	=	false

			cl.stdout	=	stdout
			cl.stderr	=	stderr
		end

		stdout.truncate(0)
		stderr.truncate(0)
		r = climate.run [ ]
		assert_equal 0, r.values.size
		assert_empty stdout.string
		assert_empty stderr.string

		stdout.truncate(0)
		stderr.truncate(0)
		r = climate.run [ 'value-1' ]
		assert_equal 1, r.values.size
		assert_empty stdout.string
		assert_empty stderr.string
	end

	def test_constrain_with_integer

		stdout	=	StringIO.new
		stderr	=	StringIO.new

		climate = LibCLImate::Climate.new do |cl|

			cl.exit_on_unknown	=	false

			cl.stdout	=	stdout
			cl.stderr	=	stderr

			cl.constrain_values = 2
		end

		stdout.truncate(0)
		stderr.truncate(0)
		r = climate.run [ ]
		assert_equal 0, r.values.size
		assert_empty stdout.string
		assert_not_empty stderr.string
		assert_match /wrong number of values.*0 given.*2 required.*/, stderr.string

		stdout.truncate(0)
		stderr.truncate(0)
		r = climate.run [ 'value-1' ]
		assert_equal 1, r.values.size
		assert_empty stdout.string
		assert_not_empty stderr.string
		assert_match /wrong number of values.*1 given.*2 required.*/, stderr.string

		stdout.truncate(0)
		stderr.truncate(0)
		r = climate.run [ 'value-1', 'value-2' ]
		assert_equal 2, r.values.size
		assert_empty stdout.string
		assert_empty stderr.string

		stdout.truncate(0)
		stderr.truncate(0)
		r = climate.run [ 'value-1', 'value-2', 'value-3' ]
		assert_equal 3, r.values.size
		assert_empty stdout.string
		assert_not_empty stderr.string
		assert_match /wrong number of values.*3 given.*2 required.*/, stderr.string
	end

	def test_constrain_with_simple_range

		stdout	=	StringIO.new
		stderr	=	StringIO.new

		climate = LibCLImate::Climate.new do |cl|

			cl.exit_on_unknown	=	false

			cl.stdout	=	stdout
			cl.stderr	=	stderr

			cl.constrain_values = 0..2
		end

		stdout.truncate(0)
		stderr.truncate(0)
		r = climate.run [ ]
		assert_equal 0, r.values.size
		assert_empty stdout.string
		assert_empty stderr.string

		stdout.truncate(0)
		stderr.truncate(0)
		r = climate.run [ 'value-1' ]
		assert_equal 1, r.values.size
		assert_empty stdout.string
		assert_empty stderr.string

		stdout.truncate(0)
		stderr.truncate(0)
		r = climate.run [ 'value-1', 'value-2' ]
		assert_equal 2, r.values.size
		assert_empty stdout.string
		assert_empty stderr.string

		stdout.truncate(0)
		stderr.truncate(0)
		r = climate.run [ 'value-1', 'value-2', 'value-3' ]
		assert_equal 3, r.values.size
		assert_empty stdout.string
		assert_not_empty stderr.string

		stdout.truncate(0)
		stderr.truncate(0)
		r = climate.run [ 'value-1', 'value-2', 'value-3', 'value-4' ]
		assert_equal 4, r.values.size
		assert_empty stdout.string
		assert_not_empty stderr.string
	end
end

