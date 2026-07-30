# **libCLImate.Ruby** Changes <!-- omit in toc -->


## 0.17.0.2 - 30th July 2026

* + added `TODO.md` and updated existing boilerplate files to use the end-of-file marker;
* ~ updated boilerplate:
  * ~ `README.md`: updated tagline placement, added license and other badges, and enhanced dependencies section with Efferent/Afferent coupling information;
  * ~ `LICENSE`: updated copyright years and format;
  * ~ `libCLImate.gemspec`: updated comment header and date;
  * ~ `.vscode/settings.json`: updated various language settings for indentation, rulers, and file associations;
  * ~ `build_gem.sh`, `generate_rdoc.sh`, `test/scratch/blankzeroes.rb`: updated dates;
* ~ updated dependencies;
* ~ tidying;
* added **.vimrc**;


## 0.17.0.1 - 5th March 2025

* **Documentation**:
  * Improved `README.md` tagline placement, expanded dependencies section with Efferent/Afferent coupling details, and added license badge;
  * Updated `CHANGES.md` with a summary of these changes;
  * Added `TODO.md` for project task tracking;
  * Updated `EXAMPLES.md` to use end-of-file marker;
* **IDE Settings (`.vscode/settings.json`)**:
  * Expanded language-specific settings for indentation, rulers, and formatting for C, C++, C#, Go, JSON, Markdown, Python, Ruby, Rust, Shellscript, and TypeScript;
  * Configured Go formatting and linting;
  * Updated file associations and search exclusions;
  * Set `git.mergeEditor` to `false`;
* **Code Formatting**: Applied consistent indentation (spaces over tabs, 2-space where applicable) in various Ruby example and test files (`examples/*.rb`, `test/unit/*.rb`, `test/scratch/*.rb`) to adhere to `.cursor/rules/ruby-standards.mdc`;


## 0.17.0 - 10th August 2024

* + added option `:value_attributes` to cause any possible value-names, as described by `#value_names`, to be applied as attributes with the given value, if any, on the command-line;
* ~ updated dependencies;
* ~ updated **CHANGES.md**;
* ~ preparatory work;
* ~ updated dependencies;
* ~ settings;
* ~ updated **run_all_unit_tests.sh** from **synesissoftware/misc-dev-scripts**;


## 0.16.0 - 1st December 2023

* + added attribute `libCLImate::Climate#double_slash_index` / `libCLImate::Climate::ParseResults#double_slash_index`;
* ~ updating dependency versions;
* ~ tidying;


## 0.15.2 - 26th June 2022

* ~ forced version update;


## 0.15.1 - 26th June 2022

* ~ updated **README.md** and Gemspec;
* ~ fix to examples;


## 0.15.0 - 29th April 2019

* + added ``Climate#parse()`` and ``Climate#parse_and_verify()`` methods;
* + added ``Climate::ParseResults()`` class, which is returned from the ``#parse()`` and ``#parse_and_verify()`` methods;
* ~ various changes to examples and improvements to documentation;


## 0.14.1 - 29th April 2019

* + added **Gemfile**


## 0.14.0 - 15th April 2019

* + ``Climate#constrain_values`` now supports ``Array`` type (as well as ``Integer`` and ``Range``);
* + added ``Climate#usage_help_suffix``, which defaults to "use --help for usage";


## 0.13.0 - 13th April 2019

* + added ``CLASP::Arguments.load()``, which allows to load argument-specifications from ``Hash`` or from YAML;
* + added examples/flag_and_option_specifications.from_DATA.rb, which illustrates use of ``__END__`` / ``DATA`` containing climate specification in YAML form;
* + added ``Climate#on_flag()`` and ``Climate#on_option()`` methods, which allow a block to be attached to an existing flag or option specification;
* ~ corrected defect whereby ``exit_on_unknown`` was used instead of ``exit_on_missing`` when checking required values;


## previous versions

T.B.C.


<!-- ########################### end of file ########################### -->
