# libCLImate.Ruby - Changes <!-- omit in toc -->


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


## 0.14.0 - 15th April 2019

* `Climate#constrain_values` now supports `Array` (as well as `Integer` and `Range`);
* added `Climate#usage_help_suffix`, defaulting to "use --help for usage";


## 0.13.0 - 13th April 2019

* added `CLASP::Arguments.load()` for loading argument-specifications from `Hash` or YAML;
* added **examples/flag_and_option_specifications.from_DATA.rb** illustrating `__END__` / `DATA` YAML climate specification;
* added `Climate#on_flag()` and `Climate#on_option()` to attach blocks to existing specifications;
* corrected defect whereby `exit_on_unknown` was used instead of `exit_on_missing` when checking required values;



<!-- ########################### end of file ########################### -->
