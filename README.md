# ![logo](https://user-images.githubusercontent.com/20217279/37953358-6847ed8a-31ee-11e8-9d3f-492e2574d7dc.png)
>  `bundle update` PRs: Automated. Annotated. Announced daily.

[![Gem version](https://img.shields.io/gem/v/unwrappr.svg?style=flat-square)](https://github.com/envato/unwrappr)
[![Gem downloads](https://img.shields.io/gem/dt/unwrappr.svg?style=flat-square)](https://rubygems.org/gems/unwrappr)
[![Build status](https://badge.buildkite.com/d7db34f910131ff2a03d31dcc0ee960a3bc5f0df2c42ec4eb4.svg?branch=master&style=flat-square)](https://buildkite.com/envato-marketplaces/unwrappr)
[![license](https://img.shields.io/github/license/mashape/apistatus.svg?style=flat-square)](https://github.com/envato/unwrappr/blob/master/LICENSE.txt)
[![PRs welcome](https://img.shields.io/badge/PRs-welcome-orange.svg?style=flat-square)](https://github.com/envato/unwrappr/issues)
[![code with heart by Envato](https://img.shields.io/badge/%3C%2F%3E%20with%20%E2%99%A5%20by-Envato%20unwrappr%20team-ff69b4.svg?style=flat-square)](https://github.com/envato/unwrappr)

## :triangular_flag_on_post: Table of Contents
- [Background](#background)
- [Experiment](#experiment)
- [Installation](#installation)
- [Usage](#usage)
- [Development](#development)
- [Assumptions](#assumptions)
- [Example](#example)
- [Contributing and Code of Conduct](#contributing)
- [License](#license)

## <a id="background"></a> :cat2: Background

[Encouraging the use and creation of open source software is one of the ways we
serve our community](https://opensource.envato.com/).

Many of Envato's products are based on free and open-source software. Many
(most) of our products are written in Ruby and use
[Bundler](https://bundler.io/) to manage their dependencies on both open- and
closed-source libraries.

Keeping dependencies up-to-date requires regular work. Some teams automate this,
others do it manually. This project seeks to reduce manual and cerebral labor
to get regular dependency updates into production.

## <a id="installation"></a> :floppy_disk: Installation

    $ gem install unwrappr

## <a id="usage"></a> :blue_book: Usage

To run this in the current working directory use...

```bash
export GITHUB_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
unwrappr
```

See https://github.com/settings/tokens to set up personal access tokens.

## <a id="development"></a> :hammer: Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## <a id="assumptions"></a> :anchor: Assumptions

- All dependencies are in Git
- Git dependencies have tags matching to gem's versions
- Git is installed on the box running Unwrappr
- The target project has its dependencies managed by bundler
- The box that this executes on has access to push branches to origin
- Annotated PRs are hosted by GitHub

## <a id="example"></a> :clapper: Example

See our `unwrappr` in action here: https://github.com/envato/unwrappr-demo/pull/2 . Please feel free to submit examples.

## <a id="license"></a> :scroll: License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## <a id="contributing"></a> :seedling: Contributing and Code of Conduct

Bug reports and pull requests are welcome on GitHub at https://github.com/envato/unwrappr. This project is intended to be a safe, welcoming space for collaboration. Everyone interacting in the unwrappr project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/envato/unwrappr/blob/master/CODE_OF_CONDUCT.md).
