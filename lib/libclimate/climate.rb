
# ######################################################################## #
# File:         lib/libclimate/climate.rb
#
# Purpose:      Definition of the ::LibCLImate::Climate class
#
# Created:      13th July 2015
# Updated:      29th April 2019
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

require 'yaml'

=begin
=end

#:stopdoc:

# TODO: Need to work with other colouring libraries, too
if !defined? Colcon # :nodoc:

	begin

		require 'colcon'
	rescue LoadError #=> x

		warn "could not load colcon library" if $DEBUG
	end
end

# We monkey-patch CLASP module's Flag and Option generator methods by
# added in an +action+ attribute (but only if it does not exist)
# and attaching the given block

class << CLASP

	alias_method :Flag_old, :Flag # :nodoc:
	alias_method :Option_old, :Option # :nodoc:

	# Defines a flag, attaching the given block
	def Flag(name, options={}, &blk)

		f = self.Flag_old(name, options)

		# anticipate this functionality being added to CLASP
		unless f.respond_to? :action

			class << f

				attr_accessor :action
			end
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

	# Defines an option, attaching the given block
	def Option(name, options={}, &blk)

		o = self.Option_old(name, options)

		# anticipate this functionality being added to CLASP
		unless o.respond_to? :action

			class << o

				attr_accessor :action
			end
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
#     cl.add_option('--flavour', alias: '-f', help: 'Specifies the flavour') do |o, sp|
#
#       program_options[:flavour] = check_flavour(o.value) or cl.abort "Invalid flavour '#{o.value}'; use --help for usage"
#     end
#
#     cl.usage_values = '<value-1> [ ... <value-N> ]'
#     cl.constrain_values = 1..100000
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

	# Represents the results obtained from +Climate#parse()+
	class ParseResults

		def initialize(climate, arguments, options)

			@climate				=	climate

			@arguments				=	arguments

			@argv					=	arguments.argv
			@argv_original_copy		=	arguments.argv_original_copy
			@specifications			=	arguments.specifications
			@program_name			=	climate.program_name
			@flags					=	arguments.flags
			@options				=	arguments.options
			@values					=	arguments.values
		end

		# (Climate) The +Climate+ instance from which this instance was obtained
		attr_reader :climate

		# ([String]) The original arguments passed into the +Climate#parse()+ method
		attr_reader :argv

		# (Array) unchanged copy of the original array of arguments passed to parse
		attr_reader :argv_original_copy

		# (Array) a frozen array of specifications
		attr_reader :specifications

		# (String) The program name
		attr_reader :program_name

		# (String) A (frozen) array of flags
		attr_reader :flags

		# (String) A (frozen) array of options
		attr_reader :options

		# (String) A (frozen) array of values
		attr_reader :values

		# Verifies the initiating command-line against the specifications,
		# raising an exception if any missing, unused, or unrecognised flags,
		# options, or values are found
		def verify(**options)

			if v = options[:raise]

				hm = {}

				hm[:raise_on_required] = v unless options.has_key?(:raise_on_required)
				hm[:raise_on_unrecognised] = v unless options.has_key?(:raise_on_unrecognised)
				hm[:raise_on_unused] = v unless options.has_key?(:raise_on_unused)

				options = options.merge hm
			end

			raise_on_required		=	options[:raise_on_required]
			raise_on_unrecognised	=	options[:raise_on_unrecognised]
			raise_on_unused			=	options[:raise_on_unused]


			# Verification:
			#
			# 1. Check arguments recognised
			# 1.a Flags
			# 1.b Options
			# 2. police any required options
			# 3. Check values

			# 1.a Flags

			self.flags.each do |flag|

				spec = specifications.detect do |sp|

					sp.kind_of?(::CLASP::FlagSpecification) && flag.name == sp.name
				end

				if spec

					if spec.respond_to?(:action) && !spec.action.nil?

						spec.action.call(flag, spec)
					end
				else

					message = make_abort_message_("unrecognised flag '#{f}'")

					if false

					elsif climate.ignore_unknown

						;
					elsif raise_on_unrecognised

						if raise_on_unrecognised.is_a?(Class)

							raise raise_on_unrecognised, message
						else

							raise RuntimeError, message
						end
					elsif climate.exit_on_unknown

						climate.abort message
					else

						if program_name && !program_name.empty?

							message = "#{program_name}: #{message}"
						end

						climate.stderr.puts message
					end
				end
			end

			# 1.b Options

			self.options.each do |option|

				spec = specifications.detect do |sp|

					sp.kind_of?(::CLASP::OptionSpecification) && option.name == sp.name
				end

				if spec

					if spec.respond_to?(:action) && !spec.action.nil?

						spec.action.call(option, spec)
					end
				else

					message = make_abort_message_("unrecognised option '#{f}'")

					if false

					elsif climate.ignore_unknown

						;
					elsif raise_on_unrecognised

						if raise_on_unrecognised.is_a?(Class)

							raise raise_on_unrecognised, message
						else

							raise RuntimeError, message
						end
					elsif climate.exit_on_unknown

						climate.abort message
					else

						if program_name && !program_name.empty?

							message = "#{program_name}: #{message}"
						end

						climate.stderr.puts message
					end
				end
			end

			# 2. police any required options

			climate.check_required_options_(specifications, self.options, [], raise_on_required)

			# 3. Check values

			climate.check_value_constraints_(values)
		end

		def flag_is_specified(id)

			!@arguments.find_flag(id).nil?
		end

		def lookup_flag(id)

			@arguments.find_flag(id)
		end

		def lookup_option(id)

			@arguments.find_option(id)
		end

	end # end class ParseResults


	#:stopdoc:

	private
	module Climate_Constants_

		GIVEN_SPECS_ = "_Given_Specs_01B59422_8407_4c89_9432_8160C52BD5AD"
	end # module Climate_Constants_

	def make_abort_message_(msg)

		if 0 != (usage_help_suffix || 0).size

			"#{msg}; #{usage_help_suffix}"
		else

			msg
		end
	end

	def show_usage_()

		options	=	{}
		options.merge! stream: stdout, program_name: program_name, version: version, exit: exit_on_usage ? 0 : nil
		options[:info_lines] = info_lines if info_lines
		options[:values] = usage_values if usage_values
		options[:flags_and_options] = flags_and_options if flags_and_options

		CLASP.show_usage specifications, options
	end

	def show_version_()

		CLASP.show_version specifications, stream: stdout, program_name: program_name, version: version, exit: exit_on_usage ? 0 : nil
	end

	def infer_version_(ctxt)

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

	def self.check_type_(v, types)

		return true if v.nil?

		types = [ types ] unless Array === types

		return true if types.empty?

		types.each do |type|

			if false

				;
			elsif :boolean == type

				return true if [ TrueClass, FalseClass ].include? v.class
			elsif type.is_a?(Class)

				return true if v.is_a?(type)
			elsif type.is_a?(Array)

				t0 = type[0]

				if t0

					#return true if v.is_a?
				else

					# Can be array of anything

					return true if v.is_a?(Array)
				end
			else

				warn "Cannot validate type of '#{v}' (#{v.class}) against type specification '#{type}'"
			end
		end

		false
	end

	def self.lookup_element_(h, types, name, path)

		if h.has_key?(name)

			r = h[name]

			unless self.check_type_(r, types)

				raise TypeError, "element '#{name}' is of type '#{r.class}' and '#{types}' is required"
			end

			return r
		end

		nil
	end

	def self.require_element_(h, types, name, path)

		unless h.has_key?(name)

			if (path || '').empty?

				raise ArgumentError, "missing top-level element '#{name}' in load configuration"
			else

				raise ArgumentError, "missing element '#{path}/#{name}' in load configuration"
			end
		else

			r = h[name]

			unless self.check_type_(r, types)

				raise TypeError, "element '#{name}' is of type '#{r.class}' and '#{types}' is required"
			end

			return r
		end
	end

	public
	def check_required_options_(specifications, options, missing, raise_on_required)

		required_specifications = specifications.select do |sp|

			sp.kind_of?(::CLASP::OptionSpecification) && sp.required?
		end

		required_specifications = Hash[required_specifications.map { |sp| [ sp.name, sp ] }]

		given_options = Hash[options.map { |o| [ o.name, o ]}]

		required_specifications.each do |k, sp|

			unless given_options.has_key? k

				message = sp.required_message

				if false

					;
				elsif raise_on_required

					if raise_on_required.is_a?(Class)

						raise raise_on_required, message
					else

						raise RuntimeError, message
					end
				elsif exit_on_missing

					self.abort message
				else

					if program_name && !program_name.empty?

						message = "#{program_name}: #{message}"
					end

					stderr.puts message
				end

				missing << sp
				#results[:missing_option_aliases] << sp
			end
		end
	end

	def check_value_constraints_(values)

		# now police the values

		values_constraint	=	constrain_values
		values_constraint	=	values_constraint.begin if ::Range === values_constraint && values_constraint.end == values_constraint.begin
		val_names			=	::Array === value_names ? value_names : []

		case values_constraint
		when nil

			;
		when ::Array

			warn "value of 'constrain_values' attribute, if an #{::Array}, must not be empty and all elements must be of type #{::Integer}" if values_constraint.empty? || !values_constraint.all? { |v| ::Integer === v }

			unless values_constraint.include? values.size

				message = make_abort_message_("wrong number of values: #{values.size} given, #{values_constraint} required")

				if exit_on_missing

					self.abort message
				else

					if program_name && !program_name.empty?

						message = "#{program_name}: #{message}"
					end

					stderr.puts message
				end
			end
		when ::Integer

			unless values.size == values_constraint

				if name = val_names[values.size]

					message = make_abort_message_(name + ' not specified')
				else

					message = make_abort_message_("wrong number of values: #{values.size} given, #{values_constraint} required")
				end

				if exit_on_missing

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

					message = make_abort_message_(name + ' not specified')
				else

					message = make_abort_message_("wrong number of values: #{values.size} givens, #{values_constraint.begin} - #{values_constraint.end - (values_constraint.exclude_end? ? 1 : 0)} required")
				end

				if exit_on_missing

					self.abort message
				else

					if program_name && !program_name.empty?

						message = "#{program_name}: #{message}"
					end

					stderr.puts message
				end
			end
		else

			warn "value of 'constrain_values' attribute - '#{constrain_values}' (#{constrain_values.class}) - of wrong type : must be #{::Array}, #{::Integer}, #{::Range}, or nil"
		end
	end
	#:startdoc:

	public

	# Loads an instance of the class, as specified by +source+, according to the given parameters
	#
	# === Signature
	#
	# * *Parameters:*
	#   - +source+:: (+Hash+, +IO+) The arguments specification, either as a Hash or an instance of an IO-implementing type containing a YAML specification
	#   - +options+:: An options hash, containing any of the following options
	#
	# * *Options:*
	#   - +:no_help_flag+ (boolean) Prevents the use of the +CLASP::Flag.Help+ flag-specification
	#   - +:no_version_flag+ (boolean) Prevents the use of the +CLASP::Flag.Version+ flag-specification
	#   - +:program_name+ (::String) An explicit program-name, which is inferred from +$0+ if this is +nil+
	#   - +:version+ (String, [Integer], [String]) A version specification. If not specified, this is inferred
	#   - +:version_context+ Object or class that defines a context for searching the version. Ignored if +:version+ is specified
	#
	# * *Block* An optional block that receives the initialising Climate instance, allowing the user to modify the attributes.
	def self.load(source, options = (options_defaulted_ = {}), &blk) # :yields: climate

		check_parameter options, 'options', allow_nil: true, type: ::Hash

		options ||= {}

		h = nil

		case source
		when ::IO

			h = YAML.load source.read
		when ::Hash

			h = source
		else

			if source.respond_to?(:to_hash)

				h = source.to_hash
			else

				raise TypeError, "#{self}.#{__method__}() 'source' argument must be a #{::Hash}, or an object implementing #{::IO}, or a type implementing 'to_hash'"
			end
		end

		_libclimate				=	require_element_(h, Hash, 'libclimate', nil)
		_exit_on_missing		=	lookup_element_(_libclimate, :boolean, 'exit_on_missing', 'libclimate')
		_ignore_unknown			=	lookup_element_(_libclimate, :boolean, 'ignore_unknown', 'libclimate')
		_exit_on_unknown		=	lookup_element_(_libclimate, :boolean, 'exit_on_unknown', 'libclimate')
		_exit_on_usage			=	lookup_element_(_libclimate, :boolean, 'exit_on_usage', 'libclimate')
		_info_lines				=	lookup_element_(_libclimate, Array, 'info_lines', 'libclimate')
		_program_name			=	lookup_element_(_libclimate, String, 'program_name', 'libclimate')
		_constrain_values		=	lookup_element_(_libclimate, [ Integer, Range ], 'constrain_values', 'libclimate')
		_flags_and_options		=	lookup_element_(_libclimate, String, 'flags_and_options', 'libclimate')
		_usage_values			=	lookup_element_(_libclimate, String, 'usage_values', 'libclimate')
		_value_names			=	lookup_element_(_libclimate, Array, 'value_names', 'libclimate')
		_version				=	lookup_element_(_libclimate, [ String, [] ], 'version', 'libclimate')

		specs					=	CLASP::Arguments.load_specifications _libclimate, options

		cl						=	Climate.new(options.merge(Climate_Constants_::GIVEN_SPECS_ => specs), &blk)

		cl.exit_on_missing		=	_exit_on_missing unless _exit_on_missing.nil?
		cl.ignore_unknown		=	_ignore_unknown unless _ignore_unknown.nil?
		cl.exit_on_unknown		=	_exit_on_unknown unless _exit_on_unknown.nil?
		cl.exit_on_usage		=	_exit_on_usage unless _exit_on_usage.nil?
		cl.info_lines			=	_info_lines unless _info_lines.nil?
		cl.program_name			=	_program_name unless _program_name.nil?
		cl.constrain_values		=	_constrain_values unless _constrain_values.nil?
		cl.flags_and_options	=	_flags_and_options unless _flags_and_options.nil?
		cl.usage_values			=	_usage_values unless _usage_values.nil?
		cl.value_names			=	_value_names unless _value_names.nil?
		cl.version				=	_version unless _version.nil?

		cl
	end

	# Creates an instance of the Climate class.
	#
	# === Signature
	#
	# * *Parameters:*
	#   - +options:+ (Hash) An options hash, containing any of the following options.
	#
	# * *Options:*
	#   - +:no_help_flag+ (boolean) Prevents the use of the +CLASP::Flag.Help+ flag-specification
	#   - +:no_version_flag+ (boolean) Prevents the use of the +CLASP::Flag.Version+ flag-specification
	#   - +:program_name+ (::String) An explicit program-name, which is inferred from +$0+ if this is +nil+
	#   - +:version+ (String, [Integer], [String]) A version specification. If not specified, this is inferred
	#   - +:version_context+ Object or class that defines a context for searching the version. Ignored if +:version+ is specified
	#
	# * *Block* An optional block that receives the initialising Climate instance, allowing the user to modify the attributes.
	def initialize(options={}, &blk) # :yields: climate

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

		given_specs			=	options[Climate_Constants_::GIVEN_SPECS_]

		@specifications		=	[]
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
		@usage_help_suffix	=	'use --help for usage'
		@usage_values		=	usage_values
		@value_names		=	[]
		version_context		=	options[:version_context]
		@version			=	options[:version] || infer_version_(version_context)

		unless options[:no_help_flag]

			f	=	CLASP::Flag.Help()

			unless f.respond_to?(:action)

				class << f

					attr_accessor :action
				end
			end

			f.action = Proc.new { show_usage_ }

			@specifications << f
		end

		unless options[:no_version_flag]

			f	=	CLASP::Flag.Version()

			unless f.respond_to?(:action)

				class << f

					attr_accessor :action
				end
			end

			f.action = Proc.new { show_version_ }

			@specifications << f
		end

		@specifications	=	@specifications + given_specs if given_specs

		yield self if block_given?
	end

	# [DEPRECATED] This method is now deprecated. Instead use +program_name=+
	def set_program_name(name)

		@program_name = name
	end

	# ([CLASP::Specification]) An array of specifications attached to the climate instance, whose contents should be modified by adding (or removing) CLASP specifications
	attr_reader :specifications
	# [DEPRECATED] Instead, use +specifications+
	def aliases; specifications; end
	# (boolean) Indicates whether exit will be called (with non-zero exit code) when a required command-line option is missing. Defaults to +true+
	attr_accessor :exit_on_missing
	# (boolean) Indicates whether unknown flags or options will be ignored. This overrides +:exit_on_unknown+. Defaults to +false+
	attr_accessor :ignore_unknown
	# (boolean) Indicates whether exit will be called (with non-zero exit code) when an unknown command-line flag or option is encountered. Defaults to +true+
	attr_accessor :exit_on_unknown
	# (boolean) Indicates whether exit will be called (with zero exit code) when usage/version is requested on the command-line. Defaults to +true+
	attr_accessor :exit_on_usage
	# ([String]) Optional array of string of program-information that will be written before the rest of the usage block when usage is requested on the command-line
	attr_accessor :info_lines
	# (String) A program name; defaults to the name of the executing script
	def program_name

		name = @program_name

		if defined?(Colcon) && @stdout.tty?

			name = "#{::Colcon::Decorations::Bold}#{name}#{::Colcon::Decorations::Unbold}"
		end

		name
	end
	# Sets the +program_name+ attribute
	attr_writer :program_name
	# @return (::IO) The output stream for normative output; defaults to $stdout
	attr_accessor :stdout
	# @return (::IO) The output stream for contingent output; defaults to $stderr
	attr_accessor :stderr
	# (Integer, Range) Optional constraint on the values that must be provided to the program
	attr_accessor :constrain_values
	# (String) Optional string to describe the flags and options section. Defaults to "[ +...+ +flags+ +and+ +options+ +...+ ]"
	attr_accessor :flags_and_options
	# (String) The string that is appended to #abort calls made during #run. Defaults to "use --help for usage"
	attr_accessor :usage_help_suffix
	# @return (::String) Optional string to describe the program values, eg \<xyz "[ { <<directory> | &lt;file> } ]"
	attr_accessor :usage_values
	# ([String]) Zero-based array of names for values to be used when that value is not present (according to the +:constrain_values+ attribute)
	attr_accessor :value_names
	# (String, [String], [Integer]) A version string or an array of integers/strings representing the version component(s)
	attr_accessor :version

	# Parse the given command-line (passed as +argv+) by the given instance
	#
	# === Signature
	#
	# * *Parameters:*
	#   - +argv+ ([String]) The array of arguments; defaults to <tt>ARGV</tt>
	#
	# === Returns
	# (ParseResults) Results
	def parse(argv = ARGV) # :yields: ParseResults

		raise ArgumentError, "argv may not be nil" if argv.nil?

		arguments = CLASP::Arguments.new argv, specifications

		ParseResults.new(self, arguments, argv)
	end

	# Parse the given command-line (passed as +argv+) by the given instance,
	# and verifies it
	#
	# === Signature
	#
	# * *Parameters:*
	#   - +argv+ ([String]) The array of arguments; defaults to <tt>ARGV</tt>
	#   - +options+ (Hash) Options
	#
	# * *Options:*
	#   - +:raise_on_required+ (boolean, Exception) Causes an/the given exception to be raised if any required options are not specified in the command-line
	#   - +:raise_on_unrecognised+ (boolean, Exception) Causes an/the given exception to be raised if any unrecognised flags/options are specified in the command-line
	#   - +:raise_on_unused+ (boolean, Exception) Causes an/the given exception to be raised if any given flags/options are not used
	#   - +:raise+ (boolean, Exception) Causes an/the given exception to be raised in all conditions
	#
	# === Returns
	# (ParseResults) Results
	def parse_and_verify(argv = ARGV, **options) # :yields: ParseResults

		r = parse argv

		r.verify(**options)

		r
	end

	# [DEPRECATED] Use +Climate#parse_and_verify()+ (but be aware that the
	# returned result is of a different type
	#
	# === Signature
	#
	# * *Parameters:*
	#   - +argv+ ([String]) The array of arguments; defaults to <tt>ARGV</tt>
	#
	# === Returns
	# an instance of a type derived from +::Hash+ with the additional
	# attributes +flags+, +options+, +values+, and +argv+.
	#
	def run(argv = ARGV) # :yields: customised +::Hash+

		raise ArgumentError, "argv may not be nil" if argv.nil?

		arguments = CLASP::Arguments.new argv, specifications

		run_ argv, arguments
	end

	private
	def run_(argv, arguments) # :nodoc:

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

		# Verification:
		#
		# 1. Check arguments recognised
		# 1.a Flags
		# 1.b Options
		# 2. police any required options
		# 3. Check values

		# 1.a Flags

		flags.each do |f|

			spec = specifications.detect do |sp|

				sp.kind_of?(::CLASP::FlagSpecification) && f.name == sp.name
			end

			if spec

				selector	=	:unhandled

				if spec.respond_to?(:action) && !spec.action.nil?

					spec.action.call(f, spec)

					selector = :handled
				end

				results[:flags][selector] << f
			else

				message = make_abort_message_("unrecognised flag '#{f}'")

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

		# 1.b Options

		options.each do |o|

			spec = specifications.detect do |sp|

				sp.kind_of?(::CLASP::OptionSpecification) && o.name == sp.name
			end

			if spec

				selector	=	:unhandled

				if spec.respond_to?(:action) && !spec.action.nil?

					spec.action.call(o, spec)

					selector = :handled
				end

				results[:options][selector] << o
			else

				message = make_abort_message_("unrecognised option '#{o}'")

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

		# 2. police any required options

		check_required_options_(specifications, results[:options][:given], results[:missing_option_aliases], false)

		# 3. Check values

		check_value_constraints_(values)



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
	public

	# Calls abort() with the given message prefixed by the program_name
	#
	# === Signature
	#
	# * *Parameters:*
	#   - +message+ (String) The message string
	#   - +options+ (Hash) An option hash, containing any of the following options
	#
	# * *Options:*
	#   - +:stream+ {optional} The output stream to use. Defaults to the value of the attribute +stderr+
	#   - +:program_name+ (String) {optional} Uses the given value rather than the +program_name+ attribute; does not prefix if the empty string
	#   - +:exit+ {optional} The exit code. Defaults to 1. Does not exit if +nil+ specified explicitly
	#
	# === Returns
	# The combined message string, if <tt>exit()</tt> not called.
	def abort(message, options={})

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

	# Adds a flag to +specifications+
	#
	# === Signature
	#
	# * *Parameters:*
	#   - +name_or_flag+ (String, ::CLASP::FlagSpecification) The flag name or instance of CLASP::FlagSpecification
	#   - +options+ (Hash) An options hash, containing any of the following options
	#
	# * *Options:*
	#   - +:alias+ (String) A single alias
	#   - +:aliases+ ([String]) An array of aliases
	#   - +:help+ (String) Description string used when writing response to "+--help+" flag
	#   - +:required+ (boolean) Indicates whether the flag is required, causing #run to fail with appropriate message if the flag is not specified in the command-line arguments
	#
	# * *Block* An optional block that is invoked when the parsed command-line contains the given flag, receiving the argument and the alias
	#
	# === Examples
	#
	# ==== Specification(s) of a flag (single statement)
	#
	def add_flag(name_or_flag, options={}, &blk)

		check_parameter name_or_flag, 'name_or_flag', allow_nil: false, types: [ ::String, ::Symbol, ::CLASP::FlagSpecification ]

		if ::CLASP::FlagSpecification === name_or_flag

			specifications << name_or_flag
		else

			specifications << CLASP.Flag(name_or_flag, **options, &blk)
		end
	end

	# Adds an option to +specifications+
	#
	# === Signature
	#
	# * *Parameters:*
	#   - +name_or_option+ (String, CLASP::OptionSpecification) The option name or instance of CLASP::OptionSpecification
	#   - +options+ (Hash) An options hash, containing any of the following options
	#
	# * *Options:*
	#   - +:alias+ (String) A single alias
	#   - +:aliases+ ([String]) An array of aliases
	#   - +:help+ (String) Description string used when writing response to "+--help+" flag
	#   - +:values_range+ ([String]) An array of strings representing the valid/expected values used when writing response to "+--help+" flag. NOTE: the current version does not validate against these values, but a future version may do so
	#   - +:default_value+ (String) The default version used when, say, for the option +--my-opt+ the command-line contain the argument "+--my-opt=+"
	#
	# * *Block* An optional block that is invoked when the parsed command-line contains the given option, receiving the argument and the alias
	#
	def add_option(name_or_option, options={}, &blk)

		check_parameter name_or_option, 'name_or_option', allow_nil: false, types: [ ::String, ::Symbol, ::CLASP::OptionSpecification ]

		if ::CLASP::OptionSpecification === name_or_option

			specifications << name_or_option
		else

			specifications << CLASP.Option(name_or_option, **options, &blk)
		end
	end

	# Adds an alias to +specifications+
	#
	# === Signature
	#
	# * *Parameters:*
	#   - +name_or_specification+ (String) The flag/option name or the valued option
	#   - +aliases+ (*[String]) One or more aliases
	#
	# === Examples
	#
	# ==== Specification(s) of a flag (single statement)
	#
	#  climate.add_flag('--mark-missing', alias: '-x')
	#
	#  climate.add_flag('--absolute-path', aliases: [ '-abs', '-p' ])
	#
	# ==== Specification(s) of a flag (multiple statements)
	#
	#  climate.add_flag('--mark-missing')
	#  climate.add_alias('--mark-missing', '-x')
	#
	#  climate.add_flag('--absolute-path')
	#  climate.add_alias('--absolute-path', '-abs', '-p')
	#
	# ==== Specification(s) of an option (single statement)
	#
	#  climate.add_option('--add-patterns', alias: '-p')
	#
	# ==== Specification(s) of an option (multiple statements)
	#
	#  climate.add_option('--add-patterns')
	#  climate.add_alias('--add-patterns', '-p')
	#
	# ==== Specification of a valued option (which has to be multiple statements)
	#
	#  climate.add_option('--verbosity', values: [ 'succinct', 'verbose' ])
	#  climate.add_alias('--verbosity=succinct', '-s')
	#  climate.add_alias('--verbosity=verbose', '-v')
	def add_alias(name_or_specification, *aliases)

		check_parameter name_or_specification, 'name_or_specification', allow_nil: false, types: [ ::String, ::Symbol, ::CLASP::FlagSpecification, ::CLASP::OptionSpecification ]
		raise ArgumentError, "must supply at least one alias" if aliases.empty?

		case name_or_specification
		when ::CLASP::FlagSpecification

			self.specifications << name_or_specification
		when ::CLASP::OptionSpecification

			self.specifications << name_or_specification
		else

			self.specifications << CLASP.Alias(name_or_specification, aliases: aliases)
		end
	end

	# Attaches a block to an already-registered flag
	#
	# === Signature
	#
	# * *Parameters:*
	#   - +name_or_flag+ (String, ::CLASP::FlagSpecification) The flag name or instance of CLASP::FlagSpecification
	#   - +options+ (Hash) An options hash, containing any of the following options. No options are recognised currently
	#
	# * *Options:*
	#
	# * *Block* A required block that is invoked when the parsed command-line contains the given flag, receiving the argument and the alias
	#
	def on_flag(name_or_flag, options={}, &blk)

		check_parameter name_or_flag, 'name_or_flag', allow_nil: false, types: [ ::String, ::Symbol, ::CLASP::FlagSpecification ]

		raise ArgumentError, "on_flag() requires a block to be given" unless block_given?

		specifications.each do |spec|

			case spec
			when CLASP::FlagSpecification

				if spec == name_or_flag

					spec.action = blk

					return true
				end
			end
		end

		warn "The Climate instance does not contain a FlagSpecification matching '#{name_or_flag}' (#{name_or_flag.class})"

		false
	end

	# Attaches a block to an already-registered option
	#
	# === Signature
	#
	# * *Parameters:*
	#   - +name_or_option+ (String, ::CLASP::OptionSpecification) The option name or instance of CLASP::OptionSpecification
	#   - +options+ (Hash) An options hash, containing any of the following options. No options are recognised currently
	#
	# * *Options:*
	#
	# * *Block* A required block that is invoked when the parsed command-line contains the given option, receiving the argument and the alias
	#
	def on_option(name_or_option, options={}, &blk)

		check_parameter name_or_option, 'name_or_option', allow_nil: false, types: [ ::String, ::Symbol, ::CLASP::OptionSpecification ]

		raise ArgumentError, "on_option() requires a block to be given" unless block_given?

		specifications.each do |spec|

			case spec
			when CLASP::OptionSpecification

				if spec == name_or_option

					spec.action = blk

					return true
				end
			end
		end

		warn "The Climate instance does not contain an OptionSpecification matching '#{name_or_option}' (#{name_or_option.class})"

		false
	end
end # class Climate
end # module LibCLImate

# ############################## end of file ############################# #


