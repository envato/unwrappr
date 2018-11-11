# frozen_string_literal: true

require 'clamp'

module Unwrappr
  def self.run_unwapper_in_pwd
    puts "Doing the unwrappr thing in #{Dir.pwd}"
    GitCommandRunner.create_branch!
    BundlerCommandRunner.bundle_update!
    GitCommandRunner.commit_and_push_changes!
    GitHub::Client.make_pull_request!
  end

  # Entry point for the app
  class CLI < Clamp::Command
    self.default_subcommand = 'all'

    option ['-v', '--version'], :flag, 'Show version' do
      puts "unwrappr v#{Unwrappr::VERSION}"
      exit(0)
    end

    subcommand 'all', 'run bundle update, push to github, '\
                      'create a pr and annotate changes' do
      def execute
        run_unwapper_in_pwd
      end
    end

    subcommand 'annotate-pull-request',
               'Annotate Gemfile.lock changes in a Github pull request' do

      option ['-r', '--repo'], 'REPO',
             'The repo in github <owner/project>',
             required: true

      option ['-p', '--pr'], 'PR',
             'The github PR number',
             required: true

      def execute
        LockFileAnnotator.annotate_github_pull_request(
          repo: repo,
          pr_number: pr.to_i
        )
      end
    end

    subcommand('clone', <<~DESCRIPTION) do
      Clone one git repository or more and create an annotated bundle update PR for each.
    DESCRIPTION

      option(['-r', '--repo'],
             'REPO',
             <<~DESCRIPTION,
               a repo in github <owner/project>, may be specified multiple times
             DESCRIPTION
             required: true,
             multivalued: true)

      def execute
        repo_list.each do |repo|
          unless Dir.exist?(repo)
            GitCommandRunner.clone_repository(
              "https://github.com/#{repo}",
              repo
            )
          end

          Dir.chdir(repo) { Unwrappr.run_unwapper_in_pwd }
        end
      end
    end
  end
end
