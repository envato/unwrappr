# frozen_string_literal: true

module Unwrappr
  module Github
    # Saves Gemfile.lock annotations as Github pull request comments.
    #
    # Implements the `annotation_sink` interface as defined by the
    # LockFileAnnotator.
    class PrSink
      def initialize(repo, pr_number, client)
        @repo = repo
        @pr_number = pr_number
        @client = client
      end

      def annotate_change(gem_change, message)
        @client.create_pull_request_comment(
          @repo,
          @pr_number,
          message,
          gem_change.sha,
          gem_change.filename,
          gem_change.line_number
        )
      end
    end
  end
end
