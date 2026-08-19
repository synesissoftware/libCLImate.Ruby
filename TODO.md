# libCLImate.Ruby - TODO <!-- omit in toc -->


## Functional improvements

* [ ] Take `make_abort_message_()` to non-`public` again;


## Performance improvements

* \<none>


## Packaging improvements

* [x] ~~~GitHub Actions~~~;
* [x] ~~~rename gemspec so the filename stem matches `spec.name` (`libCLImate.gemspec` → **libclimate-ruby.gemspec**)~~~;
* [x] ~~~obtain a **run_all_unit_tests.sh** (from **misc-dev-scripts**) that skips `tput` when `$TERM` is unset or stdout is not a TTY (CI: `tput: No value for $TERM and no -T specified`)~~~;
* [x] ~~~**libclimate-ruby.gemspec**: `required_ruby_version` is the range `>= 2.0`; **Gemfile.lock** and **.ruby-version** excluded from `spec.files`; `spec.summary` matches the README tagline; packaged **AUTHORS**, **CHANGES**, **CONTRIBUTING**, **EXAMPLES**, **FAQ**, **INSTALL**, **NEWS**, **SECURITY**, **TODO**~~~;
* [x] ~~~**Gemfile** sets `lockfile false` when Bundler supports it; stop tracking **Gemfile.lock**; CI uses `bundler-cache: false` because Bundler 4 then writes no lockfile and **ruby/setup-ruby** cache cats **Gemfile.lock**~~~;
* [x] ~~~after the packaging/boilerplate/CI baseline: bump **VERSION** and align **CHANGES**/**NEWS**~~~;


<!-- ########################### end of file ########################### -->
