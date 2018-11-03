# frozen_string_literal: true

module Unwrappr
  module Researchers
    # Checks the gem metadata to obtain a Github source repository if available.
    #
    # Implements the `gem_researcher` interface required by the
    # LockFileAnnotator.
    class GithubRepo
      GITHUB_URI_PATTERN = %r{^https?://github.com/(?<repo>[^/]+/[^/]+)}i.freeze

      def research(_gem_change, gem_change_info)
        uri = gem_change_info[:ruby_gems]&.source_code_uri
        match = GITHUB_URI_PATTERN.match(uri)
        return gem_change_info if match.nil?

        gem_change_info.merge(github_repo: match[:repo])
      end
    end
  end
end
