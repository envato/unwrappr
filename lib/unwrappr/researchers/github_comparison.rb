# frozen_string_literal: true

module Unwrappr
  module Researchers
    # Compares the old version to the new via the Github API:
    # https://developer.github.com/v3/repos/commits/#compare-two-commits
    #
    # Implements the `gem_researcher` interface required by the
    # LockFileAnnotator.
    class GithubComparison
      def initialize(client)
        @client = client
      end

      def research(gem_change, gem_change_info)
        repo = gem_change_info[:github_repo]
        return gem_change_info if repo.nil? ||
                                  gem_change.base_version.nil? ||
                                  gem_change.head_version.nil?

        gem_change_info.merge(
          github_comparison: try_comparing(repo: repo,
                                           base: gem_change.base_version,
                                           head: gem_change.head_version)
        )
      end

      private

      def try_comparing(repo:, base:, head:)
        comparison = compare(repo, "v#{base}", "v#{head}")
        comparison ||= compare(repo, base.to_s, head.to_s)
        comparison
      end

      def compare(repo, base, head)
        @client.compare(repo, base, head)
      rescue Octokit::NotFound
        nil
      end
    end
  end
end
