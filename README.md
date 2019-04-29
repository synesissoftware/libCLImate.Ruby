# libCLImate.Ruby
libCLImate, for Ruby

[![Gem Version](https://badge.fury.io/rb/libclimate-ruby.svg)](https://badge.fury.io/rb/libclimate-ruby)

## Table of Contents

1. [Introduction](#introduction)
2. [Installation](#installation)
3. [Components](#components)
4. [Examples](#examples)
5. [Project Information](#project-information)

## Introduction

**libCLImate** is a portable, lightweight mini-framework that encapsulates the common aspects of **C**ommand-**L**ine **I**nterface boilerplate, including:

- command-line argument parsing and sorting;
- provision of de-facto standard CLI facilities, such as responding to '--help' and '--version';

**libCLImate.Ruby** is the Ruby version.

## Installation

Install via **gem** as in:

```
	gem install libclimate-ruby
```

or add it to your `Gemfile`.

Use via **require**, as in:

```Ruby
require 'libclimate'
```

## Components

In common with several other variants of **libCLImate**, **libCLImate.Ruby** revolves around a ``Climate`` ``class`` whose initialiser takes a block and acts as a lightweight DSL for concise definition of a command-line parsing instance, as in:

```Ruby
options = {}
climate = LibCLImate::Climate.new do |cl|

	cl.add_flag('--debug', alias: '-d', help: 'runs in Debug mode') do

		options[:debug] = true
	end
	cl.add_option('--verbosity', alias: '-v', help: 'specifies the verbosity', values: [ 'terse', 'quiet', 'silent', 'chatty' ]) do |o, a|

		options[:verbosity] = o.value
	end
	cl.add_alias('--verbosity=chatty', '-c')

	cl.version = [ 0, 1, 0 ]

	cl.info_lines =  [

		'libCLImate.Ruby examples',
		:version,
		"Illustrates use of libCLImate.Ruby's specification of flags, options, and specifications",
		'',
	]

	cl.constrain_values = 1..2
	cl.usage_values = "<dir-1> [ <dir-2> ]"
	cl.value_names = [

		"first directory",
		"second directory",
	]
end
```

## Examples

Examples are provided in the ```examples``` directory, along with a markdown description for each. A detailed list TOC of them is provided in [EXAMPLES.md](./EXAMPLES.md).

It is instructive to see how much more succinct they are than those (offering precisely the same functionality) presented in [**CLASP.Ruby**](https://github.com/synesissoftware/CLASP.Ruby).

## Project Information

### Where to get help

[GitHub Page](https://github.com/synesissoftware/libCLImate.Ruby "GitHub Page")

### Contribution guidelines

Defect reports, feature requests, and pull requests are welcome on https://github.com/synesissoftware/libCLImate.Ruby.

### Dependencies

**libCLImate.Ruby** depends on:

* the [**CLASP.Ruby**](https://github.com/synesissoftware/CLASP.Ruby) library; and
* the [**xqsr3**](https://github.com/synesissoftware/xqsr3) library.

### Related projects

* [**CLASP**](https://github.com/synesissoftware/CLASP/)
* [**CLASP.Go**](https://github.com/synesissoftware/CLASP.Go/)
* [**CLASP.js**](https://github.com/synesissoftware/CLASP.js/)
* [**CLASP.Ruby**](https://github.com/synesissoftware/CLASP.Ruby/)
* [**libCLImate** (C/C++)](https://github.com/synesissoftware/libCLImate.Ruby)
* [**xqsr3**](https://github.com/synesissoftware.com/libCLImate.Ruby-xml/)

### License

**libCLImate.Ruby** is released under the 3-clause BSD license. See [LICENSE](./LICENSE) for details.
