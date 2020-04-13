# frozen_string_literal: true

module Unwrappr
  module Researchers
    # Checks the gem metadata to obtain a Github source repository if available.
    #
    # Implements the `gem_researcher` interface required by the
    # LockFileAnnotator.
    class GithubRepo
      GITHUB_URI_PATTERN = %r{^https?://github.com/(?<repo>[^/]+/[[:alnum:]_.-]+)}i.freeze

      def research(_gem_change, gem_change_info)
        repo = match_repo(gem_change_info, :source_code_uri) ||
               match_repo(gem_change_info, :homepage_uri)
        gem_change_info.merge(github_repo: repo)
      end

      def match_repo(gem_change_info, uri_name)
        uri = gem_change_info.dig(:ruby_gems, uri_name)
        match = GITHUB_URI_PATTERN.match(uri)
        match[:repo] if match
      end
    end
  end
end
