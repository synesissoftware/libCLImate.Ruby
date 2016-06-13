
# ######################################################################## #
# File:         lib/libclimate/climate.rb
#
# Purpose:      Definition of the ::LibCLImate::Climate class
#
# Created:      13th July 2015
# Updated:      13th June 2016
#
# Home:         http://github.com/synesissoftware/libCLImate.Ruby
#
# Author:       Matthew Wilson
#
# Copyright (c) 2015-2016, Matthew Wilson and Synesis Software
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
require 'recls'
require 'xqsr3/extensions/io'

if !defined? Colcon

	begin

		require 'colcon'
	rescue LoadError #=> x

		warn "could not load colcon library" if $DEBUG
	end
end

#:stopdoc:

# We monkey-patch CLASP module's Flag and Option generator methods by
# added in a 'block' attribute (but only if it does not exist)
# and attaching the given block

class << CLASP

	alias_method :Flag_old, :Flag
	alias_method :Option_old, :Option

	def Flag(name, options={}, &blk)

		f = self.Flag_old(name, options)

		# anticipate this functionality being added to CLASP
		return f if f.respond_to? :block

		class << f

			attr_accessor :block
		end

		if blk

			case blk.arity
			when 0, 1, 2
			else

				warn "wrong arity for flag"
			end

			f.block = blk
		end

		f
	end

	def Option(name, options={}, &blk)

		o = self.Option_old(name, options)

		# anticipate this functionality being added to CLASP
		return o if o.respond_to? :block

		class << o

			attr_accessor :block
		end

		if blk

			case blk.arity
			when 0, 1, 2
			else

				warn "wrong arity for option"
			end

			o.block = blk
		end

		o
	end
end

#:startdoc:


module LibCLImate

# Class used to gather together the CLI specification, and execute it
#
#
#
class Climate

	#:stopdoc:

	private
	def show_usage_

		options	=	{}
		options.merge! stream: stdout, program_name: program_name, version: version, exit: exit_on_usage ? 0 : nil
		options[:info_lines] = info_lines if info_lines
		options[:values] = usage_values if usage_values

		CLASP.show_usage aliases, options
	end

	def show_version_

		CLASP.show_version aliases, stream: stdout, program_name: program_name, version: version, exit: exit_on_usage ? 0 : nil
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
	#   - +:no_help_flag+:: Prevents the use of the CLASP::Flag.Help flag-alias
	#   - +:no_version_flag+:: Prevents the use of the CLASP::Version.Help flag-alias
	#
	# * *Block*:: An optional block which receives the constructing instance, allowing the user to modify the attributes.
	def initialize(options={}) # :yields: climate

		options ||=	{}

		program_name = File.basename($0)
		program_name = (program_name =~ /\.rb$/) ? "#$`(#$&)" : program_name

		if defined? Colcon

			program_name = "#{::Colcon::Decorations::Bold}#{program_name}#{::Colcon::Decorations::Unbold}"
		end

		@aliases			=	[]
		@exit_on_unknown	=	true
		@exit_on_usage		=	true
		@info_lines			=	nil
		@program_name		=	program_name
		@stdout				=	$stdout
		@stderr				=	$stderr
		@usage_values		=	usage_values
		@version			=	[]

		@aliases << CLASP::Flag.Help(handle: proc { show_usage_ }) unless options[:no_help_flag]
		@aliases << CLASP::Flag.Version(handle: proc { show_version_ }) unless options[:no_version_flag]

		yield self if block_given?
	end

	# An array of aliases attached to the climate instance, whose contents should be modified by adding (or removing) CLASP aliases
	# @return [Array] The aliases
	attr_reader :aliases
	# Indicates whether exit will be called (with non-zero exit code) when an unknown command-line flag or option is encountered
	# @return [Boolean]
	# @return *true* exit(1) will be called
	# @return *false* exit will not be called
	attr_accessor :exit_on_unknown
	# @return [Boolean] Indicates whether exit will be called (with zero exit code) when usage/version is requested on the command-line
	attr_accessor :exit_on_usage
	# @return [Array] Optional array of string of program-information that will be written before the rest of the usage block when usage is requested on the command-line
	attr_accessor :info_lines
	# @return [String] A program name; defaults to the name of the executing script
	attr_accessor :program_name
	# @return [IO] The output stream for normative output; defaults to $stdout
	attr_accessor :stdout
	# @return [IO] The output stream for contingent output; defaults to $stderr
	attr_accessor :stderr
	# @return [String] Optional string to describe the program values, eg \<xyz "[ { <<directory> | &lt;file> } ]"
	attr_accessor :usage_values
	# @return [String, Array] A version string or an array of integers representing the version components
	attr_accessor :version

	# Executes the prepared Climate instance
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
				unknown:	[]
			},

			options: {

				given:		options,
				handled:	[],
				unhandled:	[],
				unknown:	[]
			},

			values:	values
		}

		flags.each do |f|

			al = aliases.detect do |a|

				a.kind_of?(::CLASP::Flag) && f.name == a.name
			end

			if al

				selector	=	:unhandled

				# see if it has a :block attribute (which will have been
				# monkey-patched to CLASP.Flag()

				if al.respond_to?(:block) && !al.block.nil?

					al.block.call(f, al)

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

				message = "#{program_name}: unrecognised flag '#{f}'; use --help for usage"

				if exit_on_unknown

					abort message
				else

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

				# see if it has a :block attribute (which will have been
				# monkey-patched to CLASP.Option()

				if al.respond_to?(:block) && !al.block.nil?

					al.block.call(o, al)

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

				message = "#{program_name}: unrecognised option '#{o}'; use --help for usage"

				if exit_on_unknown

					abort message
				else

					stderr.puts message
				end

				results[:options][:unknown] << o
			end
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

		results
	end
end # class Climate

end # module LibCLImate

# ############################## end of file ############################# #


