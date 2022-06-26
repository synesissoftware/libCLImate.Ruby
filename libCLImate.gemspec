# gemspec for libCLImate

$:.unshift File.join(File.dirname(__FILE__), 'lib')

require 'libclimate'

require 'date'

Gem::Specification.new do |spec|

	spec.name			=	'libclimate-ruby'
	spec.version		=	LibCLImate::VERSION
	spec.date			=	Date.today.to_s
	spec.summary		=	'libCLImate.Ruby'
	spec.description	=	<<END_DESC
libCLImate is a portable, lightweight mini-framework that encapsulates the common aspects of Command-Line Interface boilerplate, including:

- command-line argument parsing and sorting, into flags, options, and values;
- validating given and/or missing arguments;
- a declarative form of specifying the CLI elements for a program, including associating blocks with flag/option specifications;
- provision of de-facto standard CLI facilities, such as responding to '--help' and '--version';

libCLImate.Ruby is the Ruby version.
END_DESC
	spec.authors		=	[ 'Matt Wilson' ]
	spec.email			=	'matthew@synesis.com.au'
	spec.homepage		=	'https://github.com/synesissoftware/libCLImate.Ruby'
	spec.license		=	'BSD-3-Clause'

	spec.required_ruby_version = '~> 2.0'

	spec.add_runtime_dependency 'clasp-ruby', [ '~> 0.22', '>= 0.22.1' ]
	spec.add_runtime_dependency 'xqsr3', [ '~> 0.37', '>= 0.37.2' ]

	spec.files			=	Dir[ 'Rakefile', '{bin,examples,lib,man,spec,test}/**/*', 'README*', 'LICENSE*' ] & `git ls-files -z`.split("\0")
end

