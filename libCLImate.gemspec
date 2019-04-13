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

END_DESC
	spec.authors		=	[ 'Matt Wilson' ]
	spec.email			=	'matthew@synesis.com.au'
	spec.homepage		=	'http://www.libclimate.org/'
	spec.license		=	'BSD-3-Clause'

	spec.required_ruby_version = '~> 2.0'

	spec.add_runtime_dependency 'clasp-ruby', [ '~> 0.19' ]
	spec.add_runtime_dependency 'xqsr3', [ '~> 0.31' ]

	spec.files			=	Dir[ 'Rakefile', '{bin,examples,lib,man,spec,test}/**/*', 'README*', 'LICENSE*' ] & `git ls-files -z`.split("\0")
end

