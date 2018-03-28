#!/usr/bin/env bash

set -e

echo
echo "+++ Running Rubocop"
echo
time bundle exec rake rubocop

echo
echo "+++ Running specs"
echo
time bundle exec rake spec
