
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "unwrappr/version"

Gem::Specification.new do |spec|
  spec.name          = "unwrappr"
  spec.version       = Unwrappr::VERSION
  spec.authors       = ["Pete Johns"]
  spec.email         = ["pete.johns@envato.com"]

  spec.summary       = %q{A tool to 'Unwrapp your gems and see whats changed easily'}
  spec.description   = %q{Lets fill this bit out later}
  spec.homepage      = "http://www.unwrappr.com.org"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'bundler', '~> 1.16'
  spec.add_dependency 'clamp'
  spec.add_dependency 'octokit', '~> 4.0'
  spec.add_dependency 'safe_shell'

  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'pry'
end
