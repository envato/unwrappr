#!/bin/bash

set -euo pipefail

echo "--- :bundler: Bundling"
bundle install --path .bundle

echo "+++ :rubocop: Running Rubocop"
bundle exec rubocop
