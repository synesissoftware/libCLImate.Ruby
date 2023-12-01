#! /usr/bin/env ruby
#
# test specifications

$:.unshift File.join(File.dirname(__FILE__), '../..', 'lib')


require 'libclimate'

require 'xqsr3/extensions/test/unit'

require 'test/unit'

require 'stringio'

class Test_Climate_minimal < Test::Unit::TestCase

	def test_option_with_flag_specifications

		options	=	{}

		climate = LibCLImate::Climate.new do |cl|

			cl.add_option('--action', alias: '-a') { |o, a| options[:action] = o.value }
			cl.add_alias('--action=list', '-l')
			cl.add_alias('--action=change', '-c')
		end

		# invoke via option
		begin
			options = {}

			argv = %w{ --action=action1 }

			r = climate.run argv

			assert_not_nil r
			assert_kind_of ::Hash, r
			assert 3 <= r.size
			assert_equal 0, r.flags[:given].size

			assert_equal 1, options.size
			assert_not_nil options[:action]
			assert_equal 'action1', options[:action]
		end

		# invoke via option specification
		begin
			options = {}

			argv = %w{ -a action2 }

			r = climate.run argv

			assert_equal 1, options.size
			assert_not_nil options[:action]
			assert_equal 'action2', options[:action]
		end

		# invoke via flag specification
		begin
			options = {}

			argv = %w{ -c }

			r = climate.run argv

			assert_equal 1, options.size
			assert_not_nil options[:action]
			assert_equal 'change', options[:action]
		end

		# invoke via flag specification
		begin
			options = {}

			argv = %w{ -l }

			r = climate.run argv

			assert_equal 1, options.size
			assert_not_nil options[:action]
			assert_equal 'list', options[:action]
		end
	end
end

# ############################## end of file ############################# #


