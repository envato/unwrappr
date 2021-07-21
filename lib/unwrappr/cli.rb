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

    subcommand 'all', 'run bundle update, push to GitHub, '\
                      'create a pr and annotate changes' do
      option ['-R', '--recursive'],
             :flag,
             'Recurse into subdirectories',
             attribute_name: :recursive

      def execute
        Unwrappr.run_unwrappr_in_pwd(base_branch: base_branch, lock_files: lock_files, recursive: recursive?)
      end
    end

    subcommand 'annotate-pull-request',
               'Annotate Gemfile.lock changes in a Github pull request' do
      option ['-r', '--repo'], 'REPO',
             'The repo in github <owner/project>',
             required: true

      option ['-p', '--pr'], 'PR',
             'The GitHub PR number',
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
               a repo in GitHub <owner/project>, may be specified multiple times
             DESCRIPTION
             required: true,
             multivalued: true)

      option ['-R', '--recursive'],
             :flag,
             'Recurse into subdirectories',
             attribute_name: :recursive

      def execute
        repo_list.each do |repo|
          GitCommandRunner.clone_repository("https://github.com/#{repo}", repo) unless Dir.exist?(repo)

          Dir.chdir(repo) do
            Unwrappr.run_unwrappr_in_pwd(base_branch: base_branch, lock_files: lock_files, recursive: recursive?)
          end
        end
      end
    end
  end

  def self.run_unwrappr_in_pwd(base_branch:, lock_files:, recursive:)
    return unless any_lockfile_present?(lock_files)

    GitCommandRunner.create_branch!(base_branch: base_branch)
    bundle_update!(lock_files: lock_files, recursive: recursive)
    GitCommandRunner.commit_and_push_changes!
    GitHub::Client.make_pull_request!(lock_files)
  end

  def self.any_lockfile_present?(lock_files)
    lock_files.any? { |lock_file| GitCommandRunner.file_exist?(lock_file) }
  end

  def self.bundle_update!(lock_files:, recursive:)
    directories(lock_files: lock_files, recursive: recursive).each do |dir|
      Dir.chdir(dir) do
        puts "Doing the unwrappr thing in #{Dir.pwd}"
        BundlerCommandRunner.bundle_update!
      end
    end
  end

  def self.directories(lock_files:, recursive:)
    if recursive
      lock_files
        .flat_map { |f| Dir.glob("**/#{f}") }
        .map { |f| File.dirname(f) }
        .uniq
    else
      %w[.]
    end
  end
end
