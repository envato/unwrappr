# frozen_string_literal: true

require 'git'
require 'logger'

module Unwrappr
  # Runs Git commands
  module GitCommandRunner
    class << self
      def create_branch!
        raise 'Not a git working dir' unless git_dir?
        raise 'failed to create branch' unless branch_created?
      end

      def commit_and_push_changes!
        raise 'failed to add git changes' unless git_added_changes?
        raise 'failed to commit changes' unless git_committed?
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

      private

      def git_dir?
        git_wrap { !current_branch_name.empty? }
      end

      def branch_created?
        timestamp = Time.now.strftime('%Y%d%m-%H%M').freeze
        git_wrap do
          git.checkout('origin/master')
          git.branch("auto_bundle_update_#{timestamp}").checkout
        end
      end

      def git_added_changes?
        git_wrap { git.add(all: true) }
      end

      def git_committed?
        git_wrap { git.commit('Automatic Bundle Update') }
      end

      def git_pushed?
        git_wrap { git.push('origin', current_branch_name) }
      end

      def git
        log_options = {}.tap do |opt|
          opt[:log] = Logger.new(STDOUT) if ENV['DEBUG']
        end

        @git ||= Git.open(Dir.pwd, log_options)
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
