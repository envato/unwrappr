module Unwrappr
  module LockFileAnnotator
    FILE_NAME = 'Gemfile.lock'
    OLD_REVISION = 'HEAD~1'
    NEW_REVISION = 'HEAD'

    def self.annotate_revisions
      old_content = GitCommandRunner.show(OLD_REVISION, FILE_NAME)
      new_content = GitCommandRunner.show(NEW_REVISION, FILE_NAME)

      annotate(old_content, new_content)
    end

    def self.annotate_files(old_file, new_file)
      annotate(File.read(old_file), File.read(new_file))
    end

    def self.annotate(old_content, new_content)

      diff = LockFileComparator.perform(old_content, new_content)
      result = []

      diff[:versions].each do |dependency:, before:, after: |
        sources_uri = RubyGems.try_get_source_code_uri(dependency)
        next if sources_uri.nil?
        next unless sources_uri =~  %r{https?://github.com/([^/]+/[^/]+)$}i

        messages = GithubChangelogBuilder.build(repository: $1, base: before, head: after)
        result << { [dependency] => messages }
      end

      result
    end
  end
end