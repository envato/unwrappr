# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Add
- Loosen Bundler depndency constraint to allow major version 4 ([#99]).
- Add Ruby 4.0 to the CI test matrix ([#99]).

[Unreleased]: https://github.com/envato/unwrappr/compare/v0.8.2...HEAD
[#99]: https://github.com/envato/unwrappr/pull/99

## [0.8.2] 2024-12-28

### Add
- Add Ruby 3.4 to the CI test matrix ([#95]).
- Add `base64` as a runtime dependency to support Ruby 3.4+ ([#95]).

[0.8.2]: https://github.com/envato/unwrappr/compare/v0.8.1...v0.8.2
[#95]: https://github.com/envato/unwrappr/pull/95

## [0.8.1] 2023-02-07

### Add
- Add Ruby 3.1 and 3.2 to the CI test matrix ([#92], [#93]).

### Fix
- Resolve a number of issues raised by Rubocop ([#92], [#93]).
- Resolve GitHub Actions Node.js 12 deprecation ([#93]).
- Remove development files from the gem package ([#94]).

### Documentation
- Document how to grab credentials from the keychain ([#91]).

[0.8.1]: https://github.com/envato/unwrappr/compare/v0.8.0...v0.8.1
[#91]: https://github.com/envato/unwrappr/pull/91
[#92]: https://github.com/envato/unwrappr/pull/92
[#93]: https://github.com/envato/unwrappr/pull/93
[#94]: https://github.com/envato/unwrappr/pull/94

## [0.8.0] 2021-07-22

### Add

- Ability to perform a `bundle update` in subdirectories with the `-R` /
  `--recursive` flag. ([#90])

[0.8.0]: https://github.com/envato/unwrappr/compare/v0.7.0...v0.8.0
[#90]: https://github.com/envato/unwrappr/pull/90

## [0.7.0] 2021-07-15

### Add
- Include link to gem contents diff in gem change annotation ([#88]).

### Fix
- Fix Rubocop issues ([#89]).

[0.7.0]: https://github.com/envato/unwrappr/compare/v0.6.0...v0.7.0
[#88]: https://github.com/envato/unwrappr/pull/88
[#89]: https://github.com/envato/unwrappr/pull/89

## [0.6.0] 2021-05-12

### Add
- Allow specification of Gemfile lock files to annotate. ([#86])

[0.6.0]: https://github.com/envato/unwrappr/compare/v0.5.0..v0.6.0
[#86]: https://github.com/envato/unwrappr/pull/86

## [0.5.0] 2021-01-04

### Add
- Support for Ruby 3. ([#79])
- Allow specification of base branch, upon which to base the pull-request
  ([#80], [#84])

### Changed
- Moved CI to GitHub Actions ([#78])
- Fixed homepage URL in gemspec ([#77])
- Default branch is now `main`([#81])
- Rename private predicate methods in GitCommandRunner to be more descriptive.
  ([#82])
- Upgrade Faraday dependency to version 1 ([#85])

[0.5.0]: https://github.com/envato/unwrappr/compare/v0.4.0..v0.5.0
[#77]: https://github.com/envato/unwrappr/pull/77
[#78]: https://github.com/envato/unwrappr/pull/78
[#79]: https://github.com/envato/unwrappr/pull/79
[#80]: https://github.com/envato/unwrappr/pull/80
[#81]: https://github.com/envato/unwrappr/pull/81
[#82]: https://github.com/envato/unwrappr/pull/82
[#84]: https://github.com/envato/unwrappr/pull/84
[#85]: https://github.com/envato/unwrappr/pull/85

## [0.4.0] 2020-04-14
### Changed
- `bundler-audit` limited to `>= 0.6.0` ([#71])

### Removed
- Support for Ruby 2.3 and 2.4 ([#73])

### Added
- Rake vulnerability CVE-2020-8130 fixes ([#72])
- Support for Ruby 2.6 and 2.7 ([#73])
- Support for version numbers including a fourth segment (_e.g._ "6.0.2.2") ([#74])
- Support for GitHub URIs including anchors ([#75])

[0.4.0]: https://github.com/envato/unwrappr/compare/v0.3.5..v0.4.0
[#71]: https://github.com/envato/unwrappr/pull/71
[#72]: https://github.com/envato/unwrappr/pull/72
[#73]: https://github.com/envato/unwrappr/pull/73
[#74]: https://github.com/envato/unwrappr/pull/74
[#75]: https://github.com/envato/unwrappr/pull/75

## [0.3.5] 2019-11-28
### Changed
- ISO 8601 Date and time format for branch name ([#68])
### Fixed
- Changelog and source links in PR annotation are specific to the version
  used in the project, not just the latest available on Rubygems.org ([#69]).

[0.3.5]: https://github.com/envato/unwrappr/compare/v0.3.4...v0.3.5
[#68]: https://github.com/envato/unwrappr/pull/68
[#69]: https://github.com/envato/unwrappr/pull/69

## [0.3.4] 2019-10-24
### Fixed
- Fix failure to annotate gem change with '.' in its name ([#65]).

[0.3.4]: https://github.com/envato/unwrappr/compare/v0.3.3...v0.3.4
[#65]: https://github.com/envato/unwrappr/pull/65

## [0.3.3] 2019-06-07
### Fixed
- Fix issue where gem install will now work on RubyGems v3 ([#61]).

[0.3.3]: https://github.com/envato/unwrappr/compare/v0.3.2...v0.3.3
[#61]: https://github.com/envato/unwrappr/pull/61

## [0.3.2] 2018-11-13
### Added
 - Specify Ruby and RubyGems requirements in gemspec ([#56]).
 - Clone one git repository or more and create an annotated bundle update PR for each ([#52]).

[0.3.2]: https://github.com/envato/unwrappr/compare/v0.3.1...v0.3.2
[#56]: https://github.com/envato/unwrappr/pull/56
[#52]: https://github.com/envato/unwrappr/pull/52

## [0.3.1] 2018-11-12
### Changed
 - Travis CI enabled ([#55]).
 - Ensure we are protected against CVE-2017-8418 ([#54]).
 - RubyGems metadata includes a description ([#49]).

[0.3.1]: https://github.com/envato/unwrappr/compare/v0.3.0...v0.3.1
[#55]: https://github.com/envato/unwrappr/pull/55
[#54]: https://github.com/envato/unwrappr/pull/54
[#49]: https://github.com/envato/unwrappr/pull/49

## [0.3.0] 2018-11-12
### Initial Release

[0.3.0]: https://github.com/envato/unwrappr/releases/tag/v0.3.0
