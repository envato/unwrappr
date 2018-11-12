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

Gem::Specification.new do |spec| # rubocop:disable Metrics/BlockLength:
  spec.name = 'unwrappr'
  spec.version = Unwrappr::VERSION
  spec.authors = AUTHORS.values
  spec.email = AUTHORS.keys

  spec.summary = "A tool to unwrap your gems and see what's changed easily"
  spec.description = 'bundle update PRs: Automated. Annotated.'
  spec.homepage = 'http://www.unwrappr.com.org'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'bundler', '~> 1.16'
  spec.add_dependency 'bundler-audit', '~> 0'
  spec.add_dependency 'clamp', '~> 1'
  spec.add_dependency 'faraday', '~> 0'
  spec.add_dependency 'git', '~> 1'
  spec.add_dependency 'octokit', '~> 4.0'
  spec.add_dependency 'safe_shell', '~> 1'

  spec.add_development_dependency 'guard', '~> 2'
  spec.add_development_dependency 'guard-rspec', '~> 4'
  spec.add_development_dependency 'pry', '~> 0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-its', '~> 1'
  spec.add_development_dependency 'rubocop', '>= 0.49.0'

  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/envato/unwrappr/issues',
    'changelog_uri' => 'https://github.com/envato/unwrappr/blob/master/CHANGELOG.md',
    'documentation_uri' => 'https://github.com/envato/unwrappr/blob/master/README.md',
    'homepage_uri' => 'https://opensource.envato.com/projects/unwrappr.html',
    'source_code_uri' => 'https://github.com/envato/unwrappr'
  }
end
