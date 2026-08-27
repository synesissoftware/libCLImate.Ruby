# libCLImate.Ruby - Changes <!-- omit in toc -->


## 0.17.3 - 28th August 2026

* library source **Home:** URLs now use `https`;
* renamed **libCLImate.gemspec** to **libclimate-ruby.gemspec** so the filename stem matches `spec.name`;
* **libclimate-ruby.gemspec**: `required_ruby_version` is the range `>= 2.0`; **Gemfile.lock** and **.ruby-version** excluded from `spec.files`; `spec.summary` matches the README tagline; packaged **AUTHORS**, **CHANGES**, **CONTRIBUTING**, **EXAMPLES**, **FAQ**, **INSTALL**, **NEWS**, **SECURITY**, **TODO**;
* **Gemfile** sets `lockfile false` when Bundler supports it; stop tracking **Gemfile.lock**;
* CI uses `bundler-cache: false` and explicit `bundle install`; **Warnings** job on Ruby **3.4**; `gem build libclimate-ruby.gemspec`;
* updated **run_all_unit_tests.sh** (from https://github.com/synesissoftware/misc-dev-scripts) to skip **tput** when **$TERM** is unset or stdout is not a TTY;
* **README.md**: dropped Downloads / GitHub-release badges; nested **Dependencies** (Efferent / Afferent); listed **oss-src-tools** as a runtime dependent; dropped the broken **xqsr3** related-project URL;
* **EXAMPLES.md** example links are repo-relative (`./examples/…`);


## 0.17.2 - 15th August 2026

* added `# frozen_string_literal: true` to all **lib/** sources;


## 0.17.1 - 30th July 2026

* fixed unrecognised flag/option reporting defect;


## 0.17.0.2 - 30th July 2026

* added **TODO.md** and updated existing boilerplate files to use the end-of-file marker;
* updated boilerplate (**README.md**, **LICENSE**, **libCLImate.gemspec**, **.vscode/settings.json**, helper scripts);
* updated **README.md** tagline placement, badges, and Efferent/Afferent dependencies section;
* updated dependencies;
* tidying;
* added **.vimrc**;


## 0.17.0.1 - 5th March 2025

* improved **README.md** tagline placement, dependencies section, and license badge;
* updated **CHANGES.md**;
* added **TODO.md**;
* updated **EXAMPLES.md** to use end-of-file marker;
* expanded **.vscode/settings.json** language and formatting settings;
* applied consistent indentation in examples and tests;


## 0.17.0 - 10th August 2024

* added option `:value_attributes` so value-names from `#value_names` are applied as attributes when present on the command-line;
* updated dependencies;
* updated **CHANGES.md**;
* preparatory work;
* settings;
* updated **run_all_unit_tests.sh** (from **synesissoftware/misc-dev-scripts**);


## 0.16.0.1 - 1st December 2023

* Merged branch double_slash_index;


## 0.16.0 - 1st December 2023

* added `libCLImate::Climate#double_slash_index` / `libCLImate::Climate::ParseResults#double_slash_index`;
* updated dependency versions;
* tidying;


## 0.15.2 - 26th June 2022

* forced version update;


## 0.15.1 - 26th June 2022

* updated **README.md** and gemspec;
* fix to examples;


## 0.15.0 - 29th April 2019

* added `Climate#parse()` and `Climate#parse_and_verify()`;
* added `Climate::ParseResults`, returned from `#parse()` and `#parse_and_verify()`;
* various example and documentation improvements;


## 0.14.1 - 29th April 2019

* added **Gemfile**;


## 0.14.0.1 - 29th April 2019

* merge;


## 0.14.0 - 15th April 2019

* `Climate#constrain_values` now supports `Array` (as well as `Integer` and `Range`);
* added `Climate#usage_help_suffix`, defaulting to "use --help for usage";


## 0.13.0 - 13th April 2019

* added `CLASP::Arguments.load()` for loading argument-specifications from `Hash` or YAML;
* added **examples/flag_and_option_specifications.from_DATA.rb** illustrating `__END__` / `DATA` YAML climate specification;
* added `Climate#on_flag()` and `Climate#on_option()` to attach blocks to existing specifications;
* corrected defect whereby `exit_on_unknown` was used instead of `exit_on_missing` when checking required values;


## 0.12.2 - 13th April 2019

* much improved documentation;


## 0.12.1 - 12th April 2019

* minor documentation fixes;


## 0.12.0 - 12th April 2019

* updated in light of CLASP's changed terminology from *[aA]lias => *[sS]pecification;


## 0.11.2 - 8th January 2018

* SimpleConsoleLogService : ~ corrected handling of symbol as severity;


## 0.11.1 - 6th January 2018

* renamed SimpleConsoleService => SimpleConsoleLogService; + added NullLogService class; + added log service class tests;


## 0.11.0 - 19th March 2019

* Climate methods #add_alias(), #add_flag(), #add_option() now take FlagAlias and OptionAlias class instances in addition to names;


## 0.10.1.1 - 19th October 2018

* dependencies;


## 0.10.1 - 6th January 2018

* added :benchmark severity level;


## 0.9.4 - 6th January 2018

* added unit-tests for stock severity levels;


## 0.9.3 - 6th January 2018

* tagged release;


## 0.9.2 - 2nd January 2018

* prefix now in [ ];


## 0.9.1 - 24th December 2017

* fixing;


## 0.8.4 - 8th January 2019

* tagged release;


## 0.8.3 - 6th September 2018

* minor changes to documentation markup;


## 0.8.2 - 13th July 2018

* merge version update;


## 0.8.1 - 18th June 2018

* now recognised PROGRAM_VER_PATCH (in the stead of PROGRAM_VER_REVISION);


## 0.8.0 - 23rd December 2017

* starting to break out impl. into Pantheios::Core;


## 0.7.4 - 7th February 2018

* merge;


## 0.7.3 - 5th February 2018

* LibCLImate::Climate::set_program_name(), which uses Colcon if available;


## 0.7.2 - 3rd January 2018

* merge version update;


## 0.7.1 - 1st January 2018

* added support for required options (based on CLASP.Ruby 0.12;


## 0.6.5 - 1st January 2018

* preparatory mods;


## 0.6.4 - 1st January 2018

* fixed the version inference;


## 0.6.3 - 22nd June 2017

* tagged release;


## 0.6.2 - 16th March 2017

* fix;


## 0.6.1 - 16th March 2017

* added inference of version;


## 0.5.8 - 17th October 2016

* tidying up contract enforcements;


## 0.5.7 - 17th October 2016

* simplified unit test;


## 0.5.6 - 17th October 2016

* updated documentation;


## 0.5.5 - 26th June 2016

* changed hash-bangs;


## 0.5.4 - 18th June 2016

* fixed lacking blocks in new add_*() methods;


## 0.5.3 - 17th June 2016

* fix;


## 0.4.1 - 14th June 2016

* tidying;


## 0.3.1 - 13th June 2016

* merge;


## 0.2.4 - 13th June 2016

* 0.2.4 changes;


## 0.2.3 - 12th June 2016

* fixed extras handling for flags;


## 0.2.2 - 11th June 2016

* merge;


## 0.2.1 - 6th June 2016

* specified ranges for dependent libraries;


## 0.1.2 - 14th May 2016

* added Climate class, and basics of API;


## 0.1.1 - 14th July 2015

* added basic skeleton (0.1.1);


<!-- ########################### end of file ########################### -->
