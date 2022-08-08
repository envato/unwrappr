# frozen_string_literal: true

require 'octokit'

module Unwrappr
  module GitHub
    # GitHub Interactions
    module Client
      class << self
        def reset_client
          @git_client = nil
          @github_token = nil
        end

        def make_pull_request!(lock_files)
          create_and_annotate_pull_request(lock_files)
        rescue Octokit::ClientError => e
          raise "Failed to create and annotate pull request: #{e}"
        end

        private

        def repo_name_and_org
          repo_url = Unwrappr::GitCommandRunner.remote.gsub(/\.git$/, '')
          pattern = %r{github.com[/:](?<org>.*)/(?<repo>.*)}
          m = pattern.match(repo_url)
          [m[:org], m[:repo]].join('/')
        end

        def create_and_annotate_pull_request(lock_files)
          pr = git_client.create_pull_request(
            repo_name_and_org,
            repo_default_branch,
            Unwrappr::GitCommandRunner.current_branch_name,
            'Automated Bundle Update',
            pull_request_body
          )
          annotate_pull_request(pr.number, lock_files)
        end

        def repo_default_branch
          git_client.repository(repo_name_and_org)
                    .default_branch
        end

        def pull_request_body
          <<~BODY
            Gems brought up-to-date with :heart: by [Unwrappr](https://github.com/envato/unwrappr).
             See individual annotations below for details.
          BODY
        end

        def annotate_pull_request(pr_number, lock_files)
          LockFileAnnotator.annotate_github_pull_request(
            repo: repo_name_and_org,
            pr_number: pr_number,
            lock_files: lock_files,
            client: git_client
          )
        end

        def git_client
          @git_client ||= Octokit::Client.new(access_token: Octokit.access_token_from_environment)
        end
      end
    end
  end
end
