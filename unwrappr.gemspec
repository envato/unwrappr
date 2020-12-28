# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'unwrappr/version'

AUTHORS = {
  'emilyn.escabarte@envato.com' => 'Emilyn Escabarte',
  'joe.sustaric@envato.com' => 'Joe Sustaric',
  'orien.madgwick@envato.com' => 'Orien Madgwick',
  'pete.johns@envato.com' => 'Pete Johns',
  'vladimir.chervanev@envato.com' => 'Vladimir Chervanev'
}.freeze

GITHUB_URL = 'https://github.com/envato/unwrappr'
HOMEPAGE_URL = 'https://opensource.envato.com/projects/unwrappr.html'

Gem::Specification.new do |spec| # rubocop:disable Metrics/BlockLength:
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

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'bundler', '< 3'
  spec.add_dependency 'bundler-audit', '>= 0.6.0'
  spec.add_dependency 'clamp', '~> 1'
  spec.add_dependency 'faraday', '~> 0'
  spec.add_dependency 'git', '~> 1'
  spec.add_dependency 'octokit', '~> 4.0'
  spec.add_dependency 'safe_shell', '~> 1'

  spec.add_development_dependency 'guard', '~> 2'
  spec.add_development_dependency 'guard-rspec', '~> 4'
  spec.add_development_dependency 'pry', '~> 0'
  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-its', '~> 1'
  spec.add_development_dependency 'rubocop', '>= 0.49.0'

  spec.metadata = {
    'bug_tracker_uri' => "#{GITHUB_URL}/issues",
    'changelog_uri' => "#{GITHUB_URL}/blob/HEAD/CHANGELOG.md",
    'documentation_uri' => "#{GITHUB_URL}/blob/HEAD/README.md",
    'homepage_uri' => HOMEPAGE_URL,
    'source_code_uri' => GITHUB_URL
  }
end
