# frozen_string_literal: true

module Unwrappr
  # TODO: write something about what this class does.
  class LockFileAnnotator
    def self.annotate_github_pull_request(
      repo:, pr_number:, client: Octokit.client
    )
      new(
        lock_file_diff_source: Github::PrSource.new(repo, pr_number, client),
        annotation_sink: Github::PrSink.new(repo, pr_number, client),
        annotation_writer_factory: AnnotationWriter,
        gem_researchers: [
          Researchers::RubyGemsInfo.new
        ]
      ).annotate
    end

    def initialize(
      lock_file_diff_source:,
      annotation_sink:,
      annotation_writer_factory:,
      gem_researchers:
    )
      @lock_file_diff_source = lock_file_diff_source
      @annotation_sink = annotation_sink
      @annotation_writer_factory = annotation_writer_factory
      @gem_researchers = gem_researchers
    end

    def annotate
      @lock_file_diff_source.each_file do |lock_file_diff|
        lock_file_diff.each_gem_change do |gem_change|
          gem_change_info = research_gem(gem_change)
          message = annotation_writer(gem_change, gem_change_info).write
          @annotation_sink.annotate_change(gem_change, message)
        end
      end
    end

    private

    def research_gem(gem_change)
      @gem_researchers.reduce({}) do |gem_change_info, researcher|
        researcher.research(gem_change, gem_change_info)
      end
    end

    def annotation_writer(gem_change, gem_change_info)
      @annotation_writer_factory.new(gem_change, gem_change_info)
    end
  end
end
