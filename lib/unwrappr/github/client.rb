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

        def make_pull_request!
          create_and_annotate_pull_request
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

        def create_and_annotate_pull_request
          pr = git_client.create_pull_request(
            repo_name_and_org,
            repo_default_branch,
            Unwrappr::GitCommandRunner.current_branch_name,
            'Automated Bundle Update',
            pull_request_body
          )
          annotate_pull_request(pr.number)
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

        def annotate_pull_request(pr_number)
          LockFileAnnotator.annotate_github_pull_request(
            repo: repo_name_and_org,
            pr_number: pr_number,
            client: git_client
          )
        end

        def git_client
          @git_client ||= Octokit::Client.new(access_token: github_token)
        end

        def github_token
          @github_token ||= ENV.fetch('GITHUB_TOKEN')
        rescue KeyError
          raise %(
Missing environment variable GITHUB_TOKEN.
See https://github.com/settings/tokens to set up personal access tokens.
Add to the environment:

    export GITHUB_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

            )
        end
      end
    end
  end
end
