# frozen_string_literal: true

require 'git'
require 'logger'

module Unwrappr
  # Runs Git commands
  module GitCommandRunner
    class << self
      def create_branch!(base_branch:)
        raise 'Not a git working dir' unless git_dir?
        raise "failed to create branch from '#{base_branch}'" unless checkout_target_branch(base_branch: base_branch)
      end

      def commit_and_push_changes!
        raise 'failed to add git changes' unless stage_all_changes
        raise 'failed to commit changes' unless commit_staged_changes
        raise 'failed to push changes' unless git_pushed?
      end

      def reset_client
        @git = nil
      end

      def show(revision, path)
        git.show(revision, path)
      rescue Git::GitExecuteError
        nil
      end

      def remote
        git.config('remote.origin.url')
      end

      def current_branch_name
        git.current_branch
      end

      def clone_repository(repo, directory)
        git_wrap { Git.clone(repo, directory) }
      end

      def file_exist?(filename)
        !git.ls_files(filename).empty?
      end

      private

      def git_dir?
        git_wrap { !current_branch_name.empty? }
      end

      def checkout_target_branch(base_branch:)
        timestamp = Time.now.strftime('%Y%m%d-%H%M').freeze
        git_wrap do
          git.checkout(base_branch) unless base_branch.nil?
          git.branch("auto_bundle_update_#{timestamp}").checkout
        end
      end

      def stage_all_changes
        git_wrap { git.add(all: true) }
      end

      def commit_staged_changes
        git_wrap { git.commit('Automatic Bundle Update') }
      end

      def git_pushed?
        git_wrap { git.push('origin', current_branch_name) }
      end

      def git
        if Dir.pwd == @git&.dir&.path
          @git
        else
          Git.open(Dir.pwd, log_options)
        end
      end

      def log_options
        {}.tap do |opt|
          opt[:log] = Logger.new($stdout) if ENV['DEBUG']
        end
      end

      def git_wrap
        yield
        true
      rescue Git::GitExecuteError
        false
      end
    end
  end
end
