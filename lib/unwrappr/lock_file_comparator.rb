# frozen_string_literal: true

require 'bundler'

module Unwrappr
  # Compares two lock files and emits a diff of versions
  module LockFileComparator
    class << self
      def perform(lock_file_content_before, lock_file_content_after)
        lock_file_before = Bundler::LockfileParser.new(lock_file_content_before)
        lock_file_after = Bundler::LockfileParser.new(lock_file_content_after)

        versions_diff = SpecVersionComparator.perform(
          specs_versions(lock_file_before),
          specs_versions(lock_file_after)
        )

        { versions: versions_diff }
      end

      private

      def specs_versions(lock_file)
        lock_file.specs.each_with_object({}) do |s, memo|
          memo[s.name.to_sym] = s.version.to_s
        end
      end
    end
  end
end
