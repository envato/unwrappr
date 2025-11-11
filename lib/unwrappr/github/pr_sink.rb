# frozen_string_literal: true

module Unwrappr
  module Github
    # Saves Gemfile.lock annotations as Github pull request comments.
    #
    # Implements the `annotation_sink` interface as defined by the
    # LockFileAnnotator.
    class PrSink
      # GitHub's abuse detection can be triggered when posting comments too quickly.
      # This delay helps prevent "was submitted too quickly" errors.
      COMMENT_DELAY_SECONDS = 1.0

      # Maximum number of retry attempts for rate-limited requests
      MAX_RETRIES = 3

      def initialize(repo, pr_number, client, delay: COMMENT_DELAY_SECONDS)
        @repo = repo
        @pr_number = pr_number
        @client = client
        @delay = delay
        @last_comment_time = nil
      end

      def annotate_change(gem_change, message)
        throttle_requests
        create_comment_with_retry(gem_change, message)
      end

      private

      def throttle_requests
        return unless @last_comment_time

        elapsed = Time.now - @last_comment_time
        sleep(@delay - elapsed) if elapsed < @delay
      end

      def create_comment_with_retry(gem_change, message)
        attempt = 0

        begin
          attempt += 1
          post_comment(gem_change, message)
          @last_comment_time = Time.now
        rescue Octokit::UnprocessableEntity => e
          handle_retry(e, attempt)
          retry
        end
      end

      def handle_retry(error, attempt)
        raise unless rate_limited?(error) && attempt < MAX_RETRIES

        wait_time = calculate_wait_time(error, attempt)
        warn "Comment submitted too quickly, retrying in #{wait_time}s (attempt #{attempt}/#{MAX_RETRIES})"
        sleep(wait_time)
      end

      def post_comment(gem_change, message)
        @client.create_pull_request_comment(
          @repo,
          @pr_number,
          message,
          gem_change.sha,
          gem_change.filename,
          gem_change.line_number
        )
      end

      def rate_limited?(error)
        error.message.include?('submitted too quickly')
      end

      def calculate_wait_time(error, attempt)
        # Check for retry-after header (GitHub tells us exactly when to retry)
        retry_after = extract_retry_after(error)
        return retry_after if retry_after

        # Fall back to exponential backoff: 2, 4, 8 seconds
        2**attempt
      end

      def extract_retry_after(error)
        return nil unless error.respond_to?(:response_headers)

        headers = error.response_headers
        return nil unless headers

        retry_after = headers['retry-after']
        return nil unless retry_after&.to_i&.positive?

        retry_after.to_i
      end
    end
  end
end
