# frozen_string_literal: true

require 'git'
require 'logger'
require 'octokit'

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

      def make_pull_request!
        raise 'failed to make pull request' unless pull_request_created?
      end

      def reset_client
        @git_client = nil
        @git = nil
      end

      def show(revision, path)
        git.show(revision, path)
      rescue Git::GitExecuteError
        nil
      end

      private

      def git_dir?
        git_wrap { !current_branch_name.empty? }
      end

      def branch_created?
        timestamp = Time.now.strftime('%Y%d%m-%H%M').freeze
        git_wrap { git.branch("auto_bundle_update_#{timestamp}").checkout }
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

      def current_branch_name
        git.current_branch
      end

      def repo_name_and_org
        repo_url = git.config('remote.origin.url')
        pattern = %r{github.com[/:](?<org>.*)/(?<repo>.*)(\.git)?}
        m = pattern.match(repo_url)
        [m[:org], m[:repo]].join('/')
      end

      def pull_request_created?
        git_client.create_pull_request(
          repo_name_and_org,
          'master',
          current_branch_name,
          'Automated Bundle Update',
          Unwrappr::LockFileAnnotator.annotate_revisions.to_s
        )
        true
      rescue Octokit::ClientError
        false
      end

      def git_client
        @git_client ||= Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
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
