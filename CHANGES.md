# **libCLImate.Ruby** Changes

## 0.17.0 - 10th August 2024

* + added option `:value_attributes` to cause any possible value-names, as described by `#value_names`, to be applied as attributes with the given value, if any, on the command-line
* ~ updated dependencies
* ~ updated **CHANGES.md**
* ~ preparatory work
* ~ updated dependencies
* ~ settings
* ~ updated **run_all_unit_tests.sh** from **synesissoftware/misc-dev-scripts**


## 0.16.0 - 1st December 2023

* + added attribute `libCLImate::Climate#double_slash_index` / `libCLImate::Climate::ParseResults#double_slash_indes`
* ~ updating dependency versions
* ~ tidying


## 0.15.2 - 26th June 2022

* ~ forced version update


## 0.15.1 - 26th June 2022

* ~ updated **README.md** and Gemspec
* ~ fix to examples


## 0.15.0 - 29th April 2019

* + added ``Climate#parse()`` and ``Climate#parse_and_verify()`` methods
* + added ``Climate::ParseResults()`` class, which is returned from the ``#parse()`` and ``#parse_and_verify()`` methods
* ~ various changes to examples and improvements to documentation


## 0.14.1 - 29th April 2019

* + added **Gemfile**


## 0.14.0 - 15th April 2019

* + ``Climate#constrain_values`` now supports ``Array`` type (as well as ``Integer`` and ``Range``)
* + added ``Climate#usage_help_suffix``, which defaults to "use --help for usage"


## 0.13.0 - 13th April 2019

* + added ``CLASP::Arguments.load()``, which allows to load argument-specifications from ``Hash`` or from YAML
* + added examples/flag_and_option_specifications.from_DATA.rb, which illustrates use of ``__END__`` / ``DATA`` containing climate specification in YAML form
* + added ``Climate#on_flag()`` and ``Climate#on_option()`` methods, which allow a block to be attached to an existing flag or option specification
* ~ corrected defect whereby ``exit_on_unknown`` was used instead of ``exit_on_missing`` when checking required values


## previous versions

T.B.C.


