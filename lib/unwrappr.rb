# frozen_string_literal: true

require 'unwrappr/bundler_command_runner'
require 'unwrappr/cli'
require 'unwrappr/gem_change'
require 'unwrappr/gem_version'
require 'unwrappr/git_command_runner'
require 'unwrappr/github/pr_sink'
require 'unwrappr/github/pr_source'
require 'unwrappr/lock_file_annotator'
require 'unwrappr/lock_file_comparator'
require 'unwrappr/lock_file_diff'
require 'unwrappr/octokit'
require 'unwrappr/researchers/composite'
require 'unwrappr/researchers/github_comparison'
require 'unwrappr/researchers/ruby_gems_info'
require 'unwrappr/ruby_gems'
require 'unwrappr/spec_version_comparator'
require 'unwrappr/version'
require 'unwrappr/writers/composite'
require 'unwrappr/writers/github_commit_log'
require 'unwrappr/writers/project_links'
require 'unwrappr/writers/title'
require 'unwrappr/writers/version_change'

# Define our namespace
module Unwrappr
end
