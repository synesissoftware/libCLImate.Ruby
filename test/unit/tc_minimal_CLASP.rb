#! /usr/bin/env ruby
#
# test simple scenarios (with CLASP)

$:.unshift File.join(File.dirname(__FILE__), '../..', 'lib')


require 'libclimate'

require 'xqsr3/extensions/test/unit'

require 'test/unit'

require 'stringio'

class Test_Climate_minimal_CLASP < Test::Unit::TestCase

  def test_no_arguments_no_mods

    climate = LibCLImate::Climate.new do |cl|

      ;
    end

    assert $stdout.equal? climate.stdout
    assert $stderr.equal? climate.stderr
  end

  def test_no_arguments_set_streams

    climate = LibCLImate::Climate.new do |cl|

      cl.stdout = $stdout
      cl.stderr = $stderr
    end

    assert $stdout.equal? climate.stdout
    assert $stderr.equal? climate.stderr
  end

  def test_help_to_string

    str = StringIO.new

    climate = LibCLImate::Climate.new do |cl|

      cl.program_name = 'program'
      cl.stdout = str
      cl.exit_on_usage = false
    end

    argv = %w{ --help }

    r = climate.run argv

    assert_not_nil r
    assert_kind_of ::Hash, r
    assert 3 <= r.size
    assert_not_nil r[:flags]
    assert_not_nil r[:options]
    assert_not_nil r[:values]
    assert_equal 4, r[:flags].size
    assert_equal 4, r.flags.size
    assert_equal 1, r[:flags][:given].size
    assert_equal 1, r[:flags][:handled].size
    assert_equal 0, r[:flags][:unhandled].size
    assert_equal 0, r[:flags][:unknown].size
    assert_equal 4, r[:options].size
    assert_equal 0, r[:options][:given].size
    assert_equal 0, r[:options][:handled].size
    assert_equal 0, r[:options][:unhandled].size
    assert_equal 0, r[:options][:unknown].size
    assert_equal 0, r[:values].size
    assert_nil r.double_slash_index

    lines = str.string.split(/\n/)
    lines = lines.reject { |line| line.chomp.strip.empty? }
    lines = lines.map { |line| line.chomp.strip }

    assert_equal 6, lines.size
    assert_equal "USAGE: program [ ... flags and options ... ]", lines[0]
    assert_equal "flags/options:", lines[1]
    assert_equal "--help", lines[2]
    assert_equal "shows this help and terminates", lines[3]
    assert_equal "--version", lines[4]
    assert_equal "shows version and terminates", lines[5]
  end

  def test_help_to_string_with_info_line

    str = StringIO.new

    climate = LibCLImate::Climate.new do |cl|

      cl.program_name = 'program'
      cl.info_lines = 'Synesis Software Open Source'
      cl.stdout = str
      cl.exit_on_usage = false
    end

    argv = %w{ --help }

    r = climate.run argv

    assert_not_nil r
    assert_kind_of ::Hash, r
    assert 3 <= r.size
    assert_not_nil r[:flags]
    assert_not_nil r[:options]
    assert_not_nil r[:values]
    assert_equal 4, r[:flags].size
    assert_equal 4, r.flags.size
    assert_equal 1, r[:flags][:given].size
    assert_equal 1, r[:flags][:handled].size
    assert_equal 0, r[:flags][:unhandled].size
    assert_equal 0, r[:flags][:unknown].size
    assert_equal 4, r[:options].size
    assert_equal 0, r[:options][:given].size
    assert_equal 0, r[:options][:handled].size
    assert_equal 0, r[:options][:unhandled].size
    assert_equal 0, r[:options][:unknown].size
    assert_equal 0, r[:values].size
    assert_nil r.double_slash_index

    lines = str.string.split(/\n/)
    lines = lines.reject { |line| line.chomp.strip.empty? }
    lines = lines.map { |line| line.chomp.strip }

    assert_equal 7, lines.size
    index = -1
    assert_equal 'Synesis Software Open Source', lines[index += 1]
    assert_equal "USAGE: program [ ... flags and options ... ]", lines[index += 1]
    assert_equal "flags/options:", lines[index += 1]
    assert_equal "--help", lines[index += 1]
    assert_equal "shows this help and terminates", lines[index += 1]
    assert_equal "--version", lines[index += 1]
    assert_equal "shows version and terminates", lines[index += 1]
  end

  def test_version_to_string

    str = StringIO.new

    climate = LibCLImate::Climate.new do |cl|

      cl.program_name = 'program'
      cl.version = [ 1, 2, 3, 4 ]
      cl.stdout = str
      cl.exit_on_usage = false
    end

    argv = %w{ --version }

    climate.run argv

    lines = str.string.split(/\n/)
    lines = lines.reject { |line| line.chomp.strip.empty? }
    lines = lines.map { |line| line.chomp.strip }

    assert_equal 1, lines.size
    assert_equal "program 1.2.3.4", lines[0]
  end

  def test_unrecognised_flag

    strout = StringIO.new
    strerr = StringIO.new

    climate = LibCLImate::Climate.new do |cl|

      cl.program_name     = 'program'
      cl.stdout           = strout
      cl.stderr           = strerr
      cl.exit_on_unknown  = false
    end

    argv = %w{ --unknown }

    climate.run argv

    lines_out = strout.string.split /\n/
    lines_err = strerr.string.split /\n/

    assert_equal 0, lines_out.size
    assert_equal 1, lines_err.size
    assert_equal "program: unrecognised flag '--unknown'; use --help for usage", lines_err[0]
  end

  def test_unrecognised_option

    strout = StringIO.new
    strerr = StringIO.new

    climate = LibCLImate::Climate.new do |cl|

      cl.program_name     = 'program'
      cl.stdout           = strout
      cl.stderr           = strerr
      cl.exit_on_unknown  = false
    end

    argv = %w{ --unknown=10 }

    climate.run argv

    lines_out = strout.string.split /\n/
    lines_err = strerr.string.split /\n/

    assert_equal 0, lines_out.size
    assert_equal 1, lines_err.size
    assert_equal "program: unrecognised option '--unknown=10'; use --help for usage", lines_err[0]
  end

  def test_one_custom_flag_help_to_string

    str = StringIO.new

    is_verbose = false

    climate = LibCLImate::Climate.new do |cl|

      cl.program_name = 'program'
      cl.stdout = str
      cl.exit_on_usage = false

      cl.add_flag('--succinct', alias: '-s', help: 'operates succinctly')
      cl.add_flag('--verbose', alias: '-v', help: 'operates verbosely') { is_verbose = true }
    end

    argv = %w{ --help --verbose --succinct }

    r = climate.run argv

    assert_not_nil r
    assert_kind_of ::Hash, r
    assert 3 <= r.size
    assert_not_nil r[:flags]
    assert_not_nil r[:options]
    assert_not_nil r[:values]
    assert_equal 4, r[:flags].size
    assert_equal 3, r[:flags][:given].size
    assert_equal 2, r[:flags][:handled].size
    assert_equal 1, r[:flags][:unhandled].size
    assert_equal 0, r[:flags][:unknown].size
    assert_equal 4, r[:options].size
    assert_equal 0, r[:options][:given].size
    assert_equal 0, r[:options][:handled].size
    assert_equal 0, r[:options][:unhandled].size
    assert_equal 0, r[:options][:unknown].size
    assert_equal 0, r[:values].size
    assert_equal 0, r.values.size
    lines = str.string.split(/\n/)
    lines = lines.reject { |line| line.chomp.strip.empty? }
    lines = lines.map { |line| line.chomp.strip }

    assert_equal 12, lines.size
    index = -1
    assert_equal "USAGE: program [ ... flags and options ... ]", lines[index += 1]
    assert_equal "flags/options:", lines[index += 1]
    assert_equal "--help", lines[index += 1]
    assert_equal "shows this help and terminates", lines[index += 1]
    assert_equal "--version", lines[index += 1]
    assert_equal "shows version and terminates", lines[index += 1]
    assert_equal "-s", lines[index += 1]
    assert_equal "--succinct", lines[index += 1]
    assert_equal "operates succinctly", lines[index += 1]
    assert_equal "-v", lines[index += 1]
    assert_equal "--verbose", lines[index += 1]
    assert_equal "operates verbosely", lines[index += 1]
  end

  def test_one_custom_flag_with_select

    str = StringIO.new

    is_verbose = false

    climate = LibCLImate::Climate.new do |cl|

      cl.program_name = 'program'
      cl.stdout = str
      cl.exit_on_usage = false

      cl.add_flag('--verbose', alias: '-v', help: 'operates verbosely') { is_verbose = true }
    end

    argv = %w{ --verbose }

    r = climate.run argv

    assert_not_nil r
    assert_kind_of ::Hash, r
    assert 3 <= r.size
    assert_not_nil r[:flags]
    assert_not_nil r[:options]
    assert_not_nil r[:values]
    assert_equal 4, r[:flags].size
    assert_equal 1, r[:flags][:given].size
    assert_equal 1, r[:flags][:handled].size
    assert_equal 0, r[:flags][:unhandled].size
    assert_equal 0, r[:flags][:unknown].size
    assert_equal 4, r[:options].size
    assert_equal 0, r[:options][:given].size
    assert_equal 0, r[:options][:handled].size
    assert_equal 0, r[:options][:unhandled].size
    assert_equal 0, r[:options][:unknown].size
    assert_equal 0, r[:values].size
    lines = str.string.split(/\n/)
    lines = lines.reject { |line| line.chomp.strip.empty? }
    lines = lines.map { |line| line.chomp.strip }

    assert_equal 0, lines.size
    assert is_verbose, "is_verbose not altered"
  end

  def test_one_custom_option_with_select

    str = StringIO.new

    verbosity = 1

    climate = LibCLImate::Climate.new do |cl|

      cl.program_name = 'program'
      cl.stdout = str
      cl.exit_on_usage = false

      cl.add_option('--verbosity', alias: '-v', help: 'determines level of verbose operation') { |o| verbosity = o.value }
    end

    argv = %w{ -v 2 }

    r = climate.run argv

    assert_not_nil r
    assert_kind_of ::Hash, r
    assert 3 <= r.size
    assert_not_nil r[:flags]
    assert_not_nil r[:options]
    assert_not_nil r[:values]
    assert_equal 4, r[:flags].size
    assert_equal 0, r[:flags][:given].size
    assert_equal 0, r[:flags][:handled].size
    assert_equal 0, r[:flags][:unhandled].size
    assert_equal 0, r[:flags][:unknown].size
    assert_equal 4, r[:options].size
    assert_equal 1, r[:options][:given].size
    assert_equal 1, r[:options][:handled].size
    assert_equal 0, r[:options][:unhandled].size
    assert_equal 0, r[:options][:unknown].size
    assert_equal 0, r[:values].size
    lines = str.string.split(/\n/)
    lines = lines.reject { |line| line.chomp.strip.empty? }
    lines = lines.map { |line| line.chomp.strip }

    assert_equal 0, lines.size
    assert_equal '2', verbosity
  end
end

# ############################## end of file ############################# #


