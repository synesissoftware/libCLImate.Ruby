#! /usr/bin/env ruby
#
# test attribute `LibCLImate::Climate#double_slash_index`

$:.unshift File.join(File.dirname(__FILE__), '../..', 'lib')


require 'libclimate'

require 'xqsr3/extensions/test/unit'

require 'test/unit'

require 'stringio'

class Test_Climate_double_slash_index < Test::Unit::TestCase

	def test_some_arguments_without_DSI

		climate = LibCLImate::Climate.new do |cl|

			cl.add_flag('--abc')

			cl.add_flag('-d')
			cl.add_flag('-e')
			cl.add_flag('-f')
		end

		argv = %w{ --abc -d -e -f }

		r = climate.run argv

		assert_not_nil r
		assert_kind_of ::Hash, r
		assert 3 <= r.size
		assert_not_nil r[:flags]
		assert_not_nil r[:options]
		assert_not_nil r[:values]
		assert_equal 4, r[:flags].size
		assert_equal 4, r.flags.size
		assert_equal 4, r[:flags][:given].size
		assert_equal 0, r[:flags][:handled].size
		assert_equal 4, r[:flags][:unhandled].size
		assert_equal 0, r[:flags][:unknown].size
		assert_equal 4, r[:options].size
		assert_equal 0, r[:options][:given].size
		assert_equal 0, r[:options][:handled].size
		assert_equal 0, r[:options][:unhandled].size
		assert_equal 0, r[:options][:unknown].size
		assert_equal 0, r[:values].size
		assert_nil r.double_slash_index
	end

	def test_some_arguments_with_DSI

		climate = LibCLImate::Climate.new do |cl|

			cl.add_flag('--abc')

			cl.add_flag('-d')
			cl.add_flag('-e')
			cl.add_flag('-f')
		end

		argv = %w{ --abc -d -- -e -f }

		r = climate.run argv

		assert_not_nil r
		assert_kind_of ::Hash, r
		assert 3 <= r.size
		assert_not_nil r[:flags]
		assert_not_nil r[:options]
		assert_not_nil r[:values]
		assert_equal 4, r[:flags].size
		assert_equal 4, r.flags.size
		assert_equal 2, r[:flags][:given].size
		assert_equal 0, r[:flags][:handled].size
		assert_equal 2, r[:flags][:unhandled].size
		assert_equal 0, r[:flags][:unknown].size
		assert_equal 4, r[:options].size
		assert_equal 0, r[:options][:given].size
		assert_equal 0, r[:options][:handled].size
		assert_equal 0, r[:options][:unhandled].size
		assert_equal 0, r[:options][:unknown].size
		assert_equal 2, r[:values].size
		assert_equal '-e', r[:values][0]
		assert_equal '-f', r[:values][1]
		assert_equal 2, r.double_slash_index
	end
end
