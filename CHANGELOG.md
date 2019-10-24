# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Fixed
- Fix failure to annotate gem change with '.' in its name.

## [0.3.3] 2019-06-07
### Fixed
- Fix issue where gem install will now work on RubyGems v3

## [0.3.2] 2018-11-13
### Added
 - Specify Ruby and RubyGems requirements in gemspec.
 - Clone one git repository or more and create an annotated bundle update PR for each.

## [0.3.1] 2018-11-12
### Changed
 - Travis CI enabled
 - Ensure we are protected against CVE-2017-8418
 - RubyGems metadata includes a description

## [0.3.0] 2018-11-12
## Initial Release
