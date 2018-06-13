# frozen_string_literal: true

require 'clamp'

module Unwrappr
  # Entry point for the app
  class CLI < Clamp::Command
    self.default_subcommand = 'all'

    option ['--version', '-v'], :flag, 'Show version' do
      puts "unwrappr v#{Unwrappr::VERSION}"
      exit(0)
    end

    subcommand 'all', 'run bundle update, push to github, '\
                      'create a pr and annotate changes' do
      def execute
        puts 'Doing the unwrappr thing...'
        GitCommandRunner.create_branch!
        BundlerCommandRunner.bundle_update!
        GitCommandRunner.commit_and_push_changes!
        GitCommandRunner.make_pull_request!
      end
    end

    subcommand 'annotate-pull-request',
               'Annotate Gemfile.lock changes in a Github pull request' do

      option '--repo', 'REPO',
             'The repo in github <owner/project>',
             required: true

      option '--pr', 'PR',
             'The github PR number',
             required: true

      def execute
        LockFileAnnotator.annotate_github_pull_request(
          repo: repo,
          pr_number: pr.to_i
        )
      end
    end
  end
end
