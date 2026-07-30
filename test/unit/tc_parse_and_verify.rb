#! /usr/bin/env ruby
#
# test version inference

$:.unshift File.join(File.dirname(__FILE__), '../..', 'lib')


require 'libclimate'

require 'xqsr3/extensions/test/unit'

require 'stringio'
require 'test/unit'


class Test_Climate_parse_and_verify < Test::Unit::TestCase

  class VerifyException < RuntimeError; end

  class MissingRequiredException < VerifyException; end
  class UnrecognisedArgumentException < VerifyException; end
  class UnusedArgumentException < VerifyException; end

  def test_empty_specs_empty_args

    stdout = StringIO.new
    stderr = StringIO.new

    climate = LibCLImate::Climate.new do |cl|

      cl.stdout = $stdout
      cl.stderr = $stderr
    end

    assert $stdout.equal? climate.stdout
    assert $stderr.equal? climate.stderr

    argv = [
    ]

    r = climate.parse_and_verify argv

    assert_eql climate, r.climate
    assert_equal 0, r.flags.size
    assert_equal 0, r.options.size
    assert_equal 0, r.values.size
    assert_nil r.double_slash_index
  end

  def test_one_flag_with_block

    stdout = StringIO.new
    stderr = StringIO.new

    debug = false

    climate = LibCLImate::Climate.new do |cl|

      cl.add_flag('--debug', alias: '-d') { debug = true }

      cl.stdout = $stdout
      cl.stderr = $stderr
    end

    assert $stdout.equal? climate.stdout
    assert $stderr.equal? climate.stderr

    argv = [

      '-d',
    ]

    r = climate.parse_and_verify argv

    assert_true debug

    assert_eql climate, r.climate
    assert_equal 1, r.flags.size
    assert_equal 0, r.options.size
    assert_equal 0, r.values.size
    assert_nil r.double_slash_index

    flag0 = r.flags[0]

    assert_equal '-d', flag0.given_name
    assert_equal '--debug', flag0.name
  end

  def test_one_option_with_block

    stdout = StringIO.new
    stderr = StringIO.new

    verb = nil

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

    r = climate.parse_and_verify argv

    assert_equal 'chatty', verb

    assert_eql climate, r.climate
    assert_equal 0, r.flags.size
    assert_equal 1, r.options.size
    assert_equal 0, r.values.size
    assert_nil r.double_slash_index

    option0 = r.options[0]

    assert_equal '-v', option0.given_name
    assert_equal '--verbosity', option0.name
  end

  def test_one_required_flag_that_is_missing

    stdout = StringIO.new
    stderr = StringIO.new

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
    ]

    assert_raise_with_message(MissingRequiredException, /.*verbosity.*not specified/) do

      climate.parse_and_verify argv, raise_on_required: MissingRequiredException
    end
  end

  def test_unrecognized_flag_raises_unrecognised_argument_exception

    stdout = StringIO.new
    stderr = StringIO.new

    climate = LibCLImate::Climate.new do |cl|

      cl.stdout = $stdout
      cl.stderr = $stderr
    end

    assert $stdout.equal? climate.stdout
    assert $stderr.equal? climate.stderr

    argv = [

      '--unrecognised-flag',
    ]

    assert_raise_with_message(UnrecognisedArgumentException, /unrecognised flag '--unrecognised-flag'/) do

      climate.parse_and_verify argv, raise_on_unrecognised: UnrecognisedArgumentException
    end
  end

  def test_unrecognized_option_raises_unrecognised_argument_exception

    stdout = StringIO.new
    stderr = StringIO.new

    climate = LibCLImate::Climate.new do |cl|

      cl.stdout = $stdout
      cl.stderr = $stderr
    end

    assert $stdout.equal? climate.stdout
    assert $stderr.equal? climate.stderr

    argv = [

      '--unrecognised-option=some_value',
    ]

    assert_raise_with_message(UnrecognisedArgumentException, /unrecognised option '--unrecognised-option=some_value'/) do

      climate.parse_and_verify argv, raise_on_unrecognised: UnrecognisedArgumentException
    end
  end

  def test_add_flag_method_exists_and_is_callable

    climate = LibCLImate::Climate.new {}

    # Assert that calling add_flag does not raise an exception
    assert_nothing_raised do

      climate.add_flag('--test-flag')
    end

    # Verify that the flag is added to specifications
    assert_equal 3, climate.specifications.size
    assert_equal '--test-flag', climate.specifications[2].name
  end

  def test_add_option_method_exists_and_is_callable

    climate = LibCLImate::Climate.new {}

    # Assert that calling add_option does not raise an exception
    assert_nothing_raised do

      climate.add_option('--test-option')
    end

    # Verify that the option is added to specifications
    assert_equal 3, climate.specifications.size
    assert_equal '--test-option', climate.specifications[2].name
  end
end

