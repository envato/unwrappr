
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'unwrappr/version'

AUTHORS = {
  'emilyn.escabarte@envato.com' => 'Emilyn Escabarte',
  'joe.sustaric@envato.com' => 'Joe Sustaric',
  'pete.johns@envato.com' => 'Pete Johns',
  'vladimir.chervanev@envato.com' => 'Vladimir Chervanev'
}.freeze

Gem::Specification.new do |spec|
  spec.name = 'unwrappr'
  spec.version = Unwrappr::VERSION
  spec.authors = AUTHORS.values
  spec.email = AUTHORS.keys

  spec.summary = "A tool to unwrap your gems and see what's changed easily"
  spec.description = "Let's fill this bit out later"
  spec.homepage = 'http://www.unwrappr.com.org'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'bundler', '~> 1.16'
  spec.add_dependency 'clamp'
  spec.add_dependency 'octokit', '~> 4.0'
  spec.add_dependency 'safe_shell'
  spec.add_dependency 'faraday'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
end
