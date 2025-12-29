# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'unwrappr/version'

AUTHORS = {
  'emilyn.escabarte@envato.com' => 'Emilyn Escabarte',
  'joe.sustaric@envato.com' => 'Joe Sustaric',
  'orien.madgwick@envato.com' => 'Orien Madgwick',
  'paj+rubygems@johnsy.com' => 'Pete Johns',
  'vladimir.chervanev@envato.com' => 'Vladimir Chervanev'
}.freeze

GITHUB_URL = 'https://github.com/envato/unwrappr'
HOMEPAGE_URL = GITHUB_URL

Gem::Specification.new do |spec| # rubocop:disable Metrics/BlockLength
  spec.name = 'unwrappr'
  spec.version = Unwrappr::VERSION
  spec.authors = AUTHORS.values
  spec.email = AUTHORS.keys

  spec.summary = "A tool to unwrap your gems and see what's changed easily"
  spec.description = 'bundle update PRs: Automated. Annotated.'
  spec.homepage = HOMEPAGE_URL
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.5'
  spec.required_rubygems_version = '>= 2.7'

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.start_with?(*%w[. CODE_OF_CONDUCT Gemfile Guardfile Rakefile bin spec unwrappr.gemspec])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'base64'
  spec.add_dependency 'bundler', '> 2', '< 5'
  spec.add_dependency 'bundler-audit', '>= 0.6.0'
  spec.add_dependency 'clamp', '~> 1'
  spec.add_dependency 'faraday', '~> 1'
  spec.add_dependency 'git', '~> 1'
  spec.add_dependency 'logger', '~> 1'
  spec.add_dependency 'octokit', '~> 4.0'
  spec.add_dependency 'safe_shell', '~> 1'

  spec.metadata = {
    'allowed_push_host' => 'https://rubygems.org',
    'bug_tracker_uri' => "#{GITHUB_URL}/issues",
    'changelog_uri' => "#{GITHUB_URL}/blob/HEAD/CHANGELOG.md",
    'documentation_uri' => "#{GITHUB_URL}/blob/HEAD/README.md",
    'homepage_uri' => HOMEPAGE_URL,
    'rubygems_mfa_required' => 'true',
    'source_code_uri' => GITHUB_URL
  }
end
