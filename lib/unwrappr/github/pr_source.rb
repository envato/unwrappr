# frozen_string_literal: true

require 'base64'

module Unwrappr
  module Github
    # Obtains Gemfile.lock changes from a Github Pull Request
    #
    # Implements the `lock_file_diff_source` interface as defined by the
    # LockFileAnnotator.
    class PrSource
      def initialize(repo, pr_number, client)
        @repo = repo
        @pr_number = pr_number
        @client = client
      end

      def each_file
        lock_file_diffs.each do |lock_file_diff|
          yield LockFileDiff.new(
            filename:   lock_file_diff.filename,
            base_file:  file_contents(lock_file_diff.filename, base_sha),
            head_file:  file_contents(lock_file_diff.filename, head_sha),
            patch:      lock_file_diff.patch,
            sha:        head_sha
          )
        end
      end

      private

      def lock_file_diffs
        @lock_file_diffs ||= @client
                             .pull_request_files(@repo, @pr_number)
                             .select do |file|
                               File.basename(file.filename) == 'Gemfile.lock'
                             end
      end

      def file_contents(filename, ref)
        Base64.decode64(
          @client.contents(@repo, path: filename, ref: ref).content
        )
      end

      def head_sha
        @head_sha ||= pull_request.head.sha
      end

      def base_sha
        @base_sha ||= pull_request.base.sha
      end

      def pull_request
        @pull_request ||= @client.pull_request(@repo, @pr_number)
      end
    end
  end
end
