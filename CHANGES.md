# **libCLImate.Ruby** Changes

## 0.14.0 - 15th April 2019

* + Climate#constrain_values now supports Array type (as well as Integer and Range)
* + added Climate#usage_help_suffix, which defaults to "use --help for usage"

## 0.13.0 - 13th April 2019

* + added CLASP::Arguments.load(), which allows to load argument-specifications from Hash or from YAML
* + added examples/flag_and_option_specifications.from_DATA.rb, which illustrates use of __END__ / DATA containing climate specification in YAML form
* + added Climate#on_flag() and Climate#on_option() methods, which allow a block to be attached to an existing flag or option specification
* ~ corrected defect whereby exit_on_unknown was used instead of exit_on_missing when checking required values


## previous versions

T.B.C.


