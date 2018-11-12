# ![logo](https://user-images.githubusercontent.com/20217279/37953358-6847ed8a-31ee-11e8-9d3f-492e2574d7dc.png)

>  `bundle update` PRs: Automated. Annotated.

Keeping dependencies up-to-date requires regular work. Some teams automate this,
others do it manually. This project seeks to reduce manual and cerebral labor
to get regular dependency updates into production.

## Features

 - Saves your team time in keeping dependencies up-to-date and understanding what's changed
 - `unwrappr` runs `bundle update`, creates a GitHub Pull Request with the changes and annotates the differences in your project's `Gemfile.lock`
 - Annotations include:
  - Major, minor and patch-level changes
  - Upgrades versus downgrades
  - Vulnerability advisory information using [bundler-audit](https://github.com/rubysec/bundler-audit)
  - Links to the home page, source code and change log (where available) of each gem

## Development status [![Build Status](https://travis-ci.org/envato/unwrappr.svg?branch=master)](https://travis-ci.org/envato/unwrappr)

`unwrappr` is used in many projects around [Envato][envato]
However, it is still undergoing development and features are likely to change
over time.

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).


## Getting started [![Gem version](https://img.shields.io/gem/v/unwrappr.svg?style=flat-square)](https://github.com/envato/unwrappr) [![Gem downloads](https://img.shields.io/gem/dt/unwrappr.svg?style=flat-square)](https://rubygems.org/gems/unwrappr)

```
$ gem install unwrappr
```

## Configuration

`unwrappr` needs a [GitHub Personal Access Token](https://github.com/settings/tokens), stored in the environment as `GITHUB_TOKEN`.

To run `unwrappr` in the current working directory use...

```bash
export GITHUB_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
unwrappr
```

See https://github.com/settings/tokens to set up personal access tokens.

## Requirements

 - Ruby (tested against v2.4 and above)
 - GitHub access (see Configuration section)

## Contact ![Join the chat at https://gitter.im/envato/unwrappr](https://badges.gitter.im/Join%20Chat.svg)

 - [GitHub project](https://github.com/envato/unwrappr)
 - [Gitter chat room](https://gitter.im/envato/unwrappr)
 - Bug reports and feature requests are welcome via [GitHub Issues](https://github.com/envato/unwrappr/issues)

## Maintainers

 - [Pete Johns](https://github.com/johnsyweb)
 - [Joe Sustaric](https://github.com/joesustaric)

## Authors

 - [Pete Johns](https://github.com/johnsyweb)
 - [Orien Madgwick](https://github.com/orien)
 - [Joe Sustaric](https://github.com/joesustaric)
 - [Vladimir Chervanev](https://github.com/vchervanev)
 - [Em Esc](https://github.com/emesc)
 - [Chun-wei Kuo](https://github.com/Domon)

## License [![license](https://img.shields.io/github/license/mashape/apistatus.svg?style=flat-square)](https://github.com/envato/unwrappr/blob/master/LICENSE.txt)

`unwrappr` uses MIT license. See
[`LICENSE.txt`](https://github.com/envato/unwrappr/blob/master/LICENSE.txt) for
details.

## Code of Conduct

We welcome contribution from everyone. Read more about it in
[`CODE_OF_CONDUCT.md`](https://github.com/envato/unwrappr/blob/master/CODE_OF_CONDUCT.md)

## Contributing [![PRs welcome](https://img.shields.io/badge/PRs-welcome-orange.svg?style=flat-square)](https://github.com/envato/unwrappr/issues)

For bug fixes, documentation changes, and features:

1. [Fork it](./fork)
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Commit your changes (`git commit -am 'Add some feature'`)
1. Push to the branch (`git push origin my-new-feature`)
1. Create a new Pull Request

For larger new features: Do everything as above, but first also make contact with the project maintainers to be sure your change fits with the project direction and you won't be wasting effort going in the wrong direction.

## About [![code with heart by Envato](https://img.shields.io/badge/%3C%2F%3E%20with%20%E2%99%A5%20by-Envato-ff69b4.svg?style=flat-square)](https://github.com/envato/unwrappr)

This project is maintained by the [Envato engineering team][webuild] and funded by [Envato][envato].

[<img src="http://opensource.envato.com/images/envato-oss-readme-logo.png" alt="Envato logo">][envato]

Encouraging the use and creation of open source software is one of the ways we
serve our community. See [our other projects][oss] or [come work with
us][careers] where you'll find an incredibly diverse, intelligent and capable
group of people who help make our company succeed and make our workplace fun,
friendly and happy.

  [webuild]: https://webuild.envato.com?utm_source=github
  [envato]: https://envato.com?utm_source=github
  [oss]: https://opensource.envato.com/?utm_source=github
  [careers]: https://envato.com/careers/?utm_source=github
