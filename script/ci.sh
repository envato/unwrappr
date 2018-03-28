#!/usr/bin/env bash

set -e

echo
echo "+++ Running specs"
echo
time bundle exec rake spec
