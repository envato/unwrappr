module Unwrappr
  module LockFileComparator
    class << self
      def perform(lock_file_content_before, lock_file_content_after)
        lock_file_before = Bundler::LockfileParser.new(lock_file_content_before)
        lock_file_after = Bundler::LockfileParser.new(lock_file_content_after)

        versions_diff = SpecVersionComparator.perform(
          specs_versions(lock_file_before),
          specs_versions(lock_file_after),
        )

        { versions: versions_diff }
      end

      private

      def specs_versions(lock_file)
        Hash[lock_file.specs.map { |s| [s.name.to_sym, s.version.to_s] }]
      end
    end
  end
end
