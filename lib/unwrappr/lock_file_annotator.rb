# frozen_string_literal: true

module Unwrappr
  # The main entry object for annotating Gemfile.lock files.
  #
  # This class has four main collaborators:
  #
  # - **lock_file_diff_source**: Provides a means of obtaining `LockFileDiff`
  #   instances.
  #
  # - **annotation_sink**: A place to send gem change annotations.
  #
  # - **gem_researcher**: Collects extra information about the gem change.
  #   Unwrapprs if you will.
  #
  # - **annotation_writer**: Collects the gem change and all the collated
  #   research and presents it in a nicely formatted annotation.
  class LockFileAnnotator
    # rubocop:disable Metrics/MethodLength
    def self.annotate_github_pull_request(
      repo:, pr_number:, client: Octokit.client
    )
      new(
        lock_file_diff_source: Github::PrSource.new(repo, pr_number, client),
        annotation_sink: Github::PrSink.new(repo, pr_number, client),
        annotation_writer: Writers::Composite.new(
          Writers::Title,
          Writers::VersionChange,
          Writers::ProjectLinks
        ),
        gem_researcher: Researchers::Composite.new(
          Researchers::RubyGemsInfo.new
        )
      ).annotate
    end
    # rubocop:enable Metrics/MethodLength

    def initialize(
      lock_file_diff_source:,
      annotation_sink:,
      annotation_writer:,
      gem_researcher:
    )
      @lock_file_diff_source = lock_file_diff_source
      @annotation_sink = annotation_sink
      @annotation_writer = annotation_writer
      @gem_researcher = gem_researcher
    end

    def annotate
      @lock_file_diff_source.each_file do |lock_file_diff|
        lock_file_diff.each_gem_change do |gem_change|
          gem_change_info = @gem_researcher.research(gem_change, {})
          message = @annotation_writer.write(gem_change, gem_change_info)
          @annotation_sink.annotate_change(gem_change, message)
        end
      end
    end
  end
end
