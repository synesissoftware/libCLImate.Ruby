# ######################################################################## #
# File:     libclimate-ruby.gemspec
#
# Purpose:  Gemspec for libCLImate.Ruby library
#
# Created:  1st March 2019
# Updated:  19th August 2026
#
# ######################################################################## #


$:.unshift File.join(File.dirname(__FILE__), 'lib')

require 'libclimate/version'


Gem::Specification.new do |spec|

  spec.name         = 'libclimate-ruby'
  spec.summary      = 'libCLImate, for Ruby'
  spec.version      = LibCLImate::VERSION
  spec.description  = <<END_DESC
libCLImate is a portable, lightweight mini-framework that encapsulates the common aspects of Command-Line Interface boilerplate, including:

- command-line argument parsing and sorting, into flags, options, and values;
- validating given and/or missing arguments;
- a declarative form of specifying the CLI elements for a program, including associating blocks with flag/option specifications;
- provision of de-facto standard CLI facilities, such as responding to '--help' and '--version';

libCLImate.Ruby is the Ruby version.
END_DESC

  spec.authors      = [
    'Matt Wilson',
  ]
  spec.email        = [
    'matthew@synesis.com.au',
  ]
  spec.homepage     = 'https://github.com/synesissoftware/libCLImate.Ruby'
  spec.license      = 'BSD-3-Clause'

  spec.required_ruby_version = [ '>= 2.0' ]

  spec.add_runtime_dependency "clasp-ruby", [ '~> 0.23', '>= 0.23.0.2' ]
  spec.add_runtime_dependency "xqsr3", [ '>= 0.39.5', '< 1.0' ]

  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/synesissoftware/libCLImate.Ruby/issues',
    'changelog_uri' => 'https://github.com/synesissoftware/libCLImate.Ruby/blob/master/CHANGES.md',
    'homepage_uri' => 'https://github.com/synesissoftware/libCLImate.Ruby',
    'source_code_uri' => 'https://github.com/synesissoftware/libCLImate.Ruby',
  }

  spec.files = Dir[
    'Rakefile',
    '{bin,examples,lib,man,spec,test}/**/*',
    'AUTHORS*',
    'CHANGES*',
    'CONTRIBUTING*',
    'EXAMPLES*',
    'FAQ*',
    'INSTALL*',
    'LICENSE*',
    'NEWS*',
    'README*',
    'SECURITY*',
    'TODO*',
  ] & `git ls-files -z`.split("\0")
  spec.files -= [
    '.ruby-version',
    'Gemfile.lock',
  ]
end


# ############################## end of file ############################# #
