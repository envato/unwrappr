#!/bin/bash

set -euo pipefail

echo "--- :bundler: Bundling"
bundle install --path .bundle

echo "+++ :rspec: Running RSpec"
bundle exec rspec
