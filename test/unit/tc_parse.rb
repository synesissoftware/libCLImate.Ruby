#! /usr/bin/env ruby
#
# test version inference

$:.unshift File.join(File.dirname(__FILE__), '../..', 'lib')


require 'libclimate'

require 'xqsr3/extensions/test/unit'

require 'test/unit'

require 'stringio'

class Test_Climate_parse < Test::Unit::TestCase

	class VerifyException < RuntimeError; end

	class MissingRequiredException < VerifyException; end
	class UnrecognisedArgumentException < VerifyException; end
	class UnusedArgumentException < VerifyException; end

	def test_empty_specs_empty_args

		stdout	=	StringIO.new
		stderr	=	StringIO.new

		climate = LibCLImate::Climate.new do |cl|

			cl.stdout = $stdout
			cl.stderr = $stderr
		end

		assert $stdout.equal? climate.stdout
		assert $stderr.equal? climate.stderr

		argv = [
		]

		r = climate.parse argv

		assert_eql climate, r.climate
		assert_equal 0, r.flags.size
		assert_equal 0, r.options.size
		assert_equal 0, r.values.size
		assert_nil r.double_slash_index

		r.verify()
	end

	def test_one_flag_with_block

		stdout	=	StringIO.new
		stderr	=	StringIO.new

		debug	=	false

		climate = LibCLImate::Climate.new do |cl|

			cl.add_flag('--debug', alias: '-d') { debug = true }

			cl.stdout = $stdout
			cl.stderr = $stderr
		end

		assert $stdout.equal? climate.stdout
		assert $stderr.equal? climate.stderr

		argv = [

			'-d',
			'--',
		]

		r = climate.parse argv

		assert_false debug

		assert_eql climate, r.climate
		assert_equal 1, r.flags.size
		assert_equal 0, r.options.size
		assert_equal 0, r.values.size
		assert_equal 1, r.double_slash_index

		flag0 = r.flags[0]

		assert_equal '-d', flag0.given_name
		assert_equal '--debug', flag0.name

		r.verify()

		assert_true debug
	end

	def test_one_option_with_block

		stdout	=	StringIO.new
		stderr	=	StringIO.new

		verb	=	nil

		climate = LibCLImate::Climate.new do |cl|

			cl.add_option('--verbosity', alias: '-v') do |o, s|

				verb = o.value
			end

			cl.stdout = $stdout
			cl.stderr = $stderr
		end

		assert $stdout.equal? climate.stdout
		assert $stderr.equal? climate.stderr

		argv = [

			'-v',
			'chatty',
		]

		r = climate.parse argv

		assert_nil verb

		assert_eql climate, r.climate
		assert_equal 0, r.flags.size
		assert_equal 1, r.options.size
		assert_equal 0, r.values.size
		assert_nil r.double_slash_index

		option0 = r.options[0]

		assert_equal '-v', option0.given_name
		assert_equal '--verbosity', option0.name

		r.verify()

		assert_equal 'chatty', verb
	end

	def test_one_required_flag_that_is_missing

		stdout	=	StringIO.new
		stderr	=	StringIO.new

		climate = LibCLImate::Climate.new do |cl|

			cl.add_option('--verbosity', alias: '-v', required: true) do |o, s|

				verb = o.value
			end

			cl.stdout = $stdout
			cl.stderr = $stderr
		end

		assert $stdout.equal? climate.stdout
		assert $stderr.equal? climate.stderr

		argv = [
			'--',
		]

		r = climate.parse argv

		assert_eql climate, r.climate
		assert_equal 0, r.flags.size
		assert_equal 0, r.options.size
		assert_equal 0, r.values.size
		assert_equal 0, r.double_slash_index

		assert_raise_with_message(MissingRequiredException, /.*verbosity.*not specified/) { r.verify(raise_on_required: MissingRequiredException) }
	end
end

