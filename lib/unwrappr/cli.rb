# frozen_string_literal: true

require 'clamp'

# Welcome to unwrappr...
module Unwrappr
  # Entry point for the app
  class CLI < Clamp::Command
    self.default_subcommand = 'all'

    option(['-b', '--base'],
           'BRANCH',
           <<~DESCRIPTION,
             the branch upon which to base the pull-request. Omit this option
             to use the current branch, or repository's default branch
             (typically 'origin/main') on clone.
           DESCRIPTION
           attribute_name: :base_branch)

    option ['-f', '--lock-file'],
           'LOCK_FILE1 [-f LOCK_FILE2] [-f LOCK_FILE3] [-f ...]',
           'The Gemfile.lock files to annotate. Useful when working with multiple lock files.',
           multivalued: true,
           default: ['Gemfile.lock'],
           attribute_name: :lock_files

    option ['-v', '--version'], :flag, 'Show version' do
      puts "unwrappr v#{Unwrappr::VERSION}"
      exit(0)
    end

    subcommand 'all', 'run bundle update, push to github, '\
                      'create a pr and annotate changes' do
      def execute
        Unwrappr.run_unwrappr_in_pwd(base_branch: base_branch, lock_files: lock_files)
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
          pr_number: pr.to_i,
          lock_files: lock_files
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

          Dir.chdir(repo) { Unwrappr.run_unwrappr_in_pwd(base_branch: base_branch, lock_files: lock_files) }
        end
      end
    end
  end

  def self.run_unwrappr_in_pwd(base_branch:, lock_files:)
    return unless any_lockfile_present?(lock_files)

    puts "Doing the unwrappr thing in #{Dir.pwd}"

    GitCommandRunner.create_branch!(base_branch: base_branch)
    BundlerCommandRunner.bundle_update!
    GitCommandRunner.commit_and_push_changes!
    GitHub::Client.make_pull_request!(lock_files)
  end

  def self.any_lockfile_present?(lock_files)
    lock_files.any? { |lock_file| GitCommandRunner.file_exist?(lock_file) }
  end
end
