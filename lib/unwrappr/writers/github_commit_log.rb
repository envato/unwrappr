# frozen_string_literal: true

module Unwrappr
  module Writers
    # Inform of the number of commits included in the change. Annotate several
    # commits, and link to the Github compare page on which we can see all the
    # commits and file changes.
    #
    # Implements the `annotation_writer` interface required by the
    # LockFileAnnotator.
    class GithubCommitLog
      MAX_COMMITS = 10
      MAX_MESSAGE = 60
      SHA_LENGTH = 7

      def self.write(gem_change, gem_change_info)
        new(gem_change, gem_change_info).write
      end

      def initialize(gem_change, gem_change_info)
        @gem_change = gem_change
        @gem_change_info = gem_change_info
      end

      def write
        return nil if comparison.nil?

        collapsed_section('Commits', <<~MESSAGE)
          A change of **#{comparison.total_commits}** commits:
          #{commit_messages.join("\n")}
          - See the full changes on [the compare page](#{comparison.html_url}).
        MESSAGE
      end

      private

      def commit_messages
        comparison.commits.first(MAX_COMMITS).map(&method(:commit_message))
      end

      def commit_message(commit)
        message = commit.commit.message.lines.first.strip
        message = "#{message[0, MAX_MESSAGE]}…" if message.length > MAX_MESSAGE
        "- (#{commit.sha[0, SHA_LENGTH]}) [#{message}](#{commit.html_url})"
      end

      def comparison
        @gem_change_info[:github_comparison]
      end

      def collapsed_section(summary, body)
        <<~MESSAGE
          <details>
          <summary>#{summary}</summary>

          #{body}

          </details>
        MESSAGE
      end
    end
  end
end
