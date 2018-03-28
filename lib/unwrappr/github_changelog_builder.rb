module Unwrappr
  class GithubChangelogBuilder
    def self.build(repository:, base:, head:)
      Octokit.client.compare(repository, base, head)
             .commits
             .map(&:commit)
             .map(&:message)
    rescue Octokit::NotFound
      []
    end
  end
end
