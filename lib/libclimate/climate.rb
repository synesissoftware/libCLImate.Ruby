
# ######################################################################## #
# File:         lib/libclimate/climate.rb
#
# Purpose:      Definition of the ::LibCLImate::Climate class
#
# Created:      13th July 2015
# Updated:      12th March 2019
#
# Home:         http://github.com/synesissoftware/libCLImate.Ruby
#
# Author:       Matthew Wilson
#
# Copyright (c) 2015-2019, Matthew Wilson and Synesis Software
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# ######################################################################## #


require 'clasp'
require 'xqsr3/extensions/io'
require 'xqsr3/quality/parameter_checking'

=begin
=end

if !defined? Colcon

	begin

		require 'colcon'
	rescue LoadError #=> x

		warn "could not load colcon library" if $DEBUG
	end
end

#:stopdoc:

# We monkey-patch CLASP module's Flag and Option generator methods by
# added in a 'action' attribute (but only if it does not exist)
# and attaching the given block

class << CLASP

	alias_method :Flag_old, :Flag
	alias_method :Option_old, :Option

	def Flag(name, options={}, &blk)

		f = self.Flag_old(name, options)

		# anticipate this functionality being added to CLASP
		return f if f.respond_to? :action

		class << f

			attr_accessor :action
		end

		if blk

			case blk.arity
			when 0, 1, 2
			else

				warn "wrong arity for flag"
			end

			f.action = blk
		end

		f
	end

	def Option(name, options={}, &blk)

		o = self.Option_old(name, options)

		# anticipate this functionality being added to CLASP
		return o if o.respond_to? :action

		class << o

			attr_accessor :action
		end

		if blk

			case blk.arity
			when 0, 1, 2
			else

				warn "wrong arity for option"
			end

			o.action = blk
		end

		o
	end
end

#:startdoc:


module LibCLImate

# Class used to gather together the CLI specification, and execute it
#
# The standard usage pattern is as follows:
#
#   PROGRAM_VERSION = [ 0, 1, 2 ]
#
#   program_options = {}
#
#   climate = LibCLImate::Climate.new do |cl|
#
#     cl.add_flag('--verbose', alias: '-v', help: 'Makes program output verbose') { program_options[:verbose] = true }
#
#     cl.add_option('--flavour', alias: '-f', help: 'Specifies the flavour') do |o, a|
#
#       program_options[:flavour] = check_flavour(o.value) or cl.abort "Invalid flavour '#{o.value}'; use --help for usage"
#     end
#
#     cl.usage_values = '<value-1> [ ... <value-N> ]'
#
#     cl.info_lines = [
#
#       'ACME CLI program (using libCLImate)',
#       :version,
#       'An example program',
#     ]
#   end
#
class Climate

	include ::Xqsr3::Quality::ParameterChecking

	#:stopdoc:

	private
	def show_usage_

		options	=	{}
		options.merge! stream: stdout, program_name: program_name, version: version, exit: exit_on_usage ? 0 : nil
		options[:info_lines] = info_lines if info_lines
		options[:values] = usage_values if usage_values
		options[:flags_and_options] = flags_and_options if flags_and_options

		CLASP.show_usage aliases, options
	end

	def show_version_

		CLASP.show_version aliases, stream: stdout, program_name: program_name, version: version, exit: exit_on_usage ? 0 : nil
	end

	def infer_version_ ctxt

		# algorithm:
		#
		# 1. PROGRAM_VERSION: loaded from ctxt / global
		# 2. PROGRAM_VER(SION)_(MAJOR|MINOR|(PATCH|REVISION)|BUILD): loaded from
		#    ctxt / global

		if ctxt

			ctxt = ctxt.class unless ::Class === ctxt

			return ctxt.const_get(:PROGRAM_VERSION) if ctxt.const_defined? :PROGRAM_VERSION

			ver = []

			if ctxt.const_defined? :PROGRAM_VER_MAJOR

				ver << ctxt.const_get(:PROGRAM_VER_MAJOR)

				if ctxt.const_defined? :PROGRAM_VER_MINOR

					ver << ctxt.const_get(:PROGRAM_VER_MINOR)

					if ctxt.const_defined?(:PROGRAM_VER_REVISION) || ctxt.const_defined?(:PROGRAM_VER_PATCH)

						if ctxt.const_defined?(:PROGRAM_VER_PATCH)

							ver << ctxt.const_get(:PROGRAM_VER_PATCH)
						else

							ver << ctxt.const_get(:PROGRAM_VER_REVISION)
						end

						if ctxt.const_defined? :PROGRAM_VER_BUILD

							ver << ctxt.const_get(:PROGRAM_VER_BUILD)
						end
					end
				end

				return ver
			end
		else

			return PROGRAM_VERSION if defined? PROGRAM_VERSION

			ver = []

			if defined? PROGRAM_VER_MAJOR

				ver << PROGRAM_VER_MAJOR

				if defined? PROGRAM_VER_MINOR

					ver << PROGRAM_VER_MINOR

					if defined?(PROGRAM_VER_REVISION) || defined?(PROGRAM_VER_PATCH)

						if defined?(PROGRAM_VER_PATCH)

							ver << PROGRAM_VER_PATCH
						else

							ver << PROGRAM_VER_REVISION
						end

						if defined? PROGRAM_VER_BUILD

							ver << PROGRAM_VER_BUILD
						end
					end
				end

				return ver
			end
		end

		nil
	end
	#:startdoc:

	public

	# Creates an instance of the Climate class.
	#
	# === Signature
	#
	# * *Parameters*:
	#   - +options:+:: An options hash, containing any of the following options.
	#
	# * *Options*:
	#   - +:no_help_flag+:: (boolean) Prevents the use of the
	#     +CLASP::Flag.Help+ flag-alias
	#   - +:no_version_flag+:: (boolean) Prevents the use of the
	#     +CLASP::Flag.Version+ flag-alias
	#   - +:program_name+:: (::String) An explicit program-name, which is
	#     inferred from +$0+ if this is +nil+
	#   - +:version+:: A version specification. If not specified, this is
	#     inferred
	#   - +:version_context+:: Object or class that defines a context for
	#     searching the version. Ignored if +:version+ is specified
	#
	# * *Block*:: An optional block which receives the constructing instance, allowing the user to modify the attributes.
	def initialize(options={}) # :yields: climate

		check_parameter options, 'options', allow_nil: true, type: ::Hash

		options ||=	{}

		check_option options, :no_help_flag, type: :boolean, allow_nil: true
		check_option options, :no_version_flag, type: :boolean, allow_nil: true
		check_option options, :program_name, type: ::String, allow_nil: true

		pr_name		=	options[:program_name]

		unless pr_name

			pr_name	=	File.basename($0)
			pr_name	=	(pr_name =~ /\.(?:bat|cmd|rb|sh)$/) ? "#$`(#$&)" : pr_name
		end

		@aliases			=	[]
		@ignore_unknown		=	false
		@exit_on_unknown	=	true
		@exit_on_missing	=	true
		@exit_on_usage		=	true
		@info_lines			=	nil
		set_program_name pr_name
		@stdout				=	$stdout
		@stderr				=	$stderr
		@constrain_values	=	nil
		@flags_and_options	=	flags_and_options
		@usage_values		=	usage_values
		@value_names		=	[]
		version_context		=	options[:version_context]
		@version			=	options[:version] || infer_version_(version_context)

		@aliases << CLASP::Flag.Help(handle: proc { show_usage_ }) unless options[:no_help_flag]
		@aliases << CLASP::Flag.Version(handle: proc { show_version_ }) unless options[:no_version_flag]

		yield self if block_given?
	end

	# [DEPRECATED] This method is now deprecated. Instead use
	#  +program_name=+
	#
	# @deprecated
	def set_program_name name

		@program_name	=	name
	end

	# An array of aliases attached to the climate instance, whose contents should be modified by adding (or removing) CLASP aliases
	# @return (::Array) The aliases
	attr_reader :aliases
	# Indicates whether exit will be called (with non-zero exit code) when a
	# required command-line option is missing
	# @return (boolean)
	# @return *true* exit(1) will be called
	# @return *false* exit will not be called
	attr_accessor :exit_on_missing
	# Indicates whether unknown flags or options will be ignored. This
	# overrides +:exit_on_unknown+
	attr_accessor :ignore_unknown
	# Indicates whether exit will be called (with non-zero exit code) when an unknown command-line flag or option is encountered
	# @return (boolean)
	# @return *true* exit(1) will be called
	# @return *false* exit will not be called
	attr_accessor :exit_on_unknown
	# @return (boolean) Indicates whether exit will be called (with zero exit code) when usage/version is requested on the command-line
	attr_accessor :exit_on_usage
	# @return (::Array) Optional array of string of program-information that will be written before the rest of the usage block when usage is requested on the command-line
	attr_accessor :info_lines
	# @return (::String) A program name; defaults to the name of the executing script
	def program_name

		name = @program_name

		if defined?(Colcon) && @stdout.tty?

			name = "#{::Colcon::Decorations::Bold}#{name}#{::Colcon::Decorations::Unbold}"
		end

		name
	end
	attr_writer :program_name
	# @return (::IO) The output stream for normative output; defaults to $stdout
	attr_accessor :stdout
	# @return (::IO) The output stream for contingent output; defaults to $stderr
	attr_accessor :stderr
	# @return (::Integer, ::Range) Optional constraint on the values that
	#  must be provided to the program
	attr_accessor :constrain_values
	# @return (::String) Optional string to describe the flags and options
	# section
	attr_accessor :flags_and_options
	# @return (::String) Optional string to describe the program values, eg \<xyz "[ { <<directory> | &lt;file> } ]"
	attr_accessor :usage_values
	# @return (::Array) Zero-based array of names for values to be used when
	#  that value is not present (according to the +:constrain_values+
	#  attribute)
	attr_accessor :value_names
	# @return (::String, ::Array) A version string or an array of integers representing the version component(s)
	attr_accessor :version

	# Executes the prepared Climate instance
	#
	# == Signature
	#
	# * *Parameters*:
	#   - +argv+:: The array of arguments; defaults to <tt>ARGV</tt>
	#
	# * *Returns*:
	#   an instance of a type derived from +::Hash+ with the additional
	#   attributes +flags+, +options+, +values+, and +argv+.
	#
	def run argv = ARGV

		raise ArgumentError, "argv may not be nil" if argv.nil?

		arguments	=	CLASP::Arguments.new argv, aliases
		flags		=	arguments.flags
		options		=	arguments.options
		values		=	arguments.values.to_a

		results		=	{

			flags: {

				given:		flags,
				handled:	[],
				unhandled:	[],
				unknown:	[],
			},

			options: {

				given:		options,
				handled:	[],
				unhandled:	[],
				unknown:	[],
			},

			values:	values,

			missing_option_aliases: [],
		}

		flags.each do |f|

			al = aliases.detect do |a|

				a.kind_of?(::CLASP::Flag) && f.name == a.name
			end

			if al

				selector	=	:unhandled

				# see if it has an :action attribute (which will have been
				# monkey-patched to CLASP.Flag()

				if al.respond_to?(:action) && !al.action.nil?

					al.action.call(f, al)

					selector = :handled
				else

					ex = al.extras

					case ex
					when ::Hash

						if ex.has_key? :handle

							ex[:handle].call(f, al)

							selector = :handled
						end
					end
				end

				results[:flags][selector] << f
			else

				message = "unrecognised flag '#{f}'; use --help for usage"

				if false

				elsif ignore_unknown

					;
				elsif exit_on_unknown

					self.abort message
				else

					if program_name && !program_name.empty?

						message = "#{program_name}: #{message}"
					end

					stderr.puts message
				end

				results[:flags][:unknown] << f
			end
		end

		options.each do |o|

			al = aliases.detect do |a|

				a.kind_of?(::CLASP::Option) && o.name == a.name
			end

			if al

				selector	=	:unhandled

				# see if it has an :action attribute (which will have been
				# monkey-patched to CLASP.Option()

				if al.respond_to?(:action) && !al.action.nil?

					al.action.call(o, al)

					selector = :handled
				else

					ex = al.extras

					case ex
					when ::Hash

						if ex.has_key? :handle

							ex[:handle].call(o, al)

							selector = :handled
						end
					end
				end

				results[:options][selector] << o
			else

				message = "unrecognised option '#{o}'; use --help for usage"

				if false

				elsif ignore_unknown

					;
				elsif exit_on_unknown

					self.abort message
				else

					if program_name && !program_name.empty?

						message = "#{program_name}: #{message}"
					end

					stderr.puts message
				end

				results[:options][:unknown] << o
			end
		end


		# now police any required options

		required_aliases = aliases.select do |a|

			a.kind_of?(::CLASP::Option) && a.required?
		end

		required_aliases = Hash[required_aliases.map { |a| [ a.name, a ] }]

		given_options = Hash[results[:options][:given].map { |o| [ o.name, o ]}]

		required_aliases.each do |k, a|

			unless given_options.has_key? k

				message = a.required_message

				if exit_on_missing

					self.abort message
				else

					if program_name && !program_name.empty?

						message = "#{program_name}: #{message}"
					end

					stderr.puts message
				end

				results[:missing_option_aliases] << a
			end
		end

		# now police the values

		values_constraint	=	constrain_values
		values_constraint	=	values_constraint.begin if ::Range === values_constraint && values_constraint.end == values_constraint.begin
		val_names			=	::Array === value_names ? value_names : []

		case values_constraint
		when nil

			;
		when ::Integer

			unless values.size == values_constraint

				if name = val_names[values.size]

					message = name + ' not specified; use --help for usage'
				else

					message = "wrong number of values: #{values.size} given, #{values_constraint} required; use --help for usage"
				end

				if exit_on_unknown

					self.abort message
				else

					if program_name && !program_name.empty?

						message = "#{program_name}: #{message}"
					end

					stderr.puts message
				end
			end
		when ::Range

			unless values_constraint.include? values.size

				if name = val_names[values.size]

					message = name + ' not specified; use --help for usage'
				else

					message = "wrong number of values: #{values.size} givens, #{values_constraint.begin} - #{values_constraint.end - (values_constraint.exclude_end? ? 1 : 0)} required; use --help for usage"
				end

				if exit_on_unknown

					self.abort message
				else

					if program_name && !program_name.empty?

						message = "#{program_name}: #{message}"
					end

					stderr.puts message
				end
			end
		else

			warn "value of 'constrain_values' attribute - '#{constrain_values}' (#{constrain_values.class}) - of wrong type : must be #{::Integer}, #{::Range}, or nil"
		end



		def results.flags

			self[:flags]
		end

		def results.options

			self[:options]
		end

		def results.values

			self[:values]
		end

		results.define_singleton_method(:argv) do

			argv
		end

		results
	end

	# Calls abort() with the given message prefixed by the program_name
	#
	# === Signature
	#
	# * *Parameters*:
	#   - +message+:: The message string
	#   - +options+:: An option hash, containing any of the following options
	#
	# * *Options*:
	#   - +:stream+:: {optional} The output stream to use. Defaults to the value of the attribute +stderr+.
	#   - +:program_name+:: {optional} Uses the given value rather than the +program_name+ attribute; does not prefix if the empty string
	#   - +:exit+:: {optional} The exit code. Defaults to 1. Does not exit if +nil+ specified.
	#
	# * *Return*:
	#   The combined message string, if <tt>exit()</tt> not called.
	def abort message, options={}

		prog_name	=	options[:program_name]
		prog_name	||=	program_name
		prog_name	||=	''

		stream		=	options[:stream]
		stream		||=	stderr
		stream		||=	$stderr

		exit_code	=	options.has_key?(:exit) ? options[:exit] : 1

		if prog_name.empty?

			msg = message
		else

			msg = "#{prog_name}: #{message}"
		end


		stream.puts msg

		exit(exit_code) if exit_code

		msg
	end

	# Adds a flag to +aliases+
	#
	# === Signature
	#
	# * *Parameters*
	#   - +name_or_flag+:: The flag name or instance of CLASP::Flag
	#   - +options+:: An options hash, containing any of the following options.
	#
	# * *Options*
	#   - +:help+:: 
	#   - +:alias+:: 
	#   - +:aliases+:: 
	#   - +:extras+:: 
	def add_flag(name_or_flag, options={}, &block)

		check_parameter name_or_flag, 'name_or_flag', allow_nil: false, types: [ ::String, ::Symbol, ::CLASP::Flag ]

		if ::CLASP::Flag === name_or_flag

			aliases << name_or_flag
		else

			aliases << CLASP.Flag(name_or_flag, **options, &block)
		end
	end

	# Adds an option to +aliases+
	#
	# === Signature
	#
	# * *Parameters*
	#   - +name_or_option+:: The option name or instance of CLASP::Option
	#   - +options+:: An options hash, containing any of the following options.
	#
	# * *Options*
	#   - +:alias+:: 
	#   - +:aliases+:: 
	#   - +:help+:: 
	#   - +:values_range+:: 
	#   - +:default_value+:: 
	#   - +:extras+:: 
	def add_option(name_or_option, options={}, &block)

		check_parameter name_or_option, 'name_or_option', allow_nil: false, types: [ ::String, ::Symbol, ::CLASP::Option ]

		if ::CLASP::Option === name_or_option

			aliases << name_or_option
		else

			aliases << CLASP.Option(name_or_option, **options, &block)
		end
	end

	# Adds an alias to +aliases+
	#
	# === Signature
	#
	# * *Parameters*
	#   - +name_or_alias+:: The flag/option name or the valued option
	#   - +aliases+:: One or more aliases
	#
	# === Examples
	#
	# ==== Alias(es) of a flag (single statement)
	#
	# +climate.add_flag('--mark-missing', alias: '-x')+
	#
	# +climate.add_flag('--absolute-path', aliases: [ '-abs', '-p' ])+
	#
	# ==== Alias(es) of a flag (multiple statements)
	#
	# +climate.add_flag('--mark-missing')+
	# +climate.add_alias('--mark-missing', '-x')+
	#
	# +climate.add_flag('--absolute-path')+
	# +climate.add_alias('--absolute-path', '-abs', '-p')+
	#
	# ==== Alias(es) of an option (single statement)
	#
	# +climate.add_option('--add-patterns', alias: '-p')+
	#
	# ==== Alias(es) of an option (multiple statements)
	#
	# +climate.add_option('--add-patterns')+
	# +climate.add_alias('--add-patterns', '-p')+
	#
	# ==== Alias of a valued option (which has to be multiple statements)
	#
	# +climate.add_option('--verbosity')+
	# +climate.add_alias('--verbosity=succinct', '-s')+
	# +climate.add_alias('--verbosity=verbose', '-v')+
	def add_alias(name_or_alias, *aliases)

		check_parameter name_or_alias, 'name_or_alias', allow_nil: false, types: [ ::String, ::Symbol, ::CLASP::Flag, ::CLASP::Option ]
		raise ArgumentError, "must supply at least one alias" if aliases.empty?

		case name_or_alias
		when ::CLASP::Flag

			self.aliases << name_or_alias
		when ::CLASP::Option

			self.aliases << name_or_alias
		else

			self.aliases << CLASP.Alias(name_or_alias, aliases: aliases)
		end
	end
end # class Climate

end # module LibCLImate

# ############################## end of file ############################# #


