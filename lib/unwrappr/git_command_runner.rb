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
      end

      private

      def git_dir?
        !current_branch_name.empty?
      end

      def branch_created?
        timestamp = Time.now.strftime('%Y%d%m-%H%M').freeze
        git.branch("auto_bundle_update_#{timestamp}").checkout
        true
      end

      def git_added_changes?
        git.add(all: true)
        true
      end

      def git_committed?
        git.commit('Automatic Bundle Update')
        true
      end

      def git_pushed?
        git.push
        true
      end

      def current_branch_name
        git.current_branch
      end

      def repo_name_and_org
        repo = git.config('remote.origin.url')
        # expect "git@github.com:org_name/repo_name.git\n"
        # return org_name/repo_name
        repo.split(':')[1].split('.')[0].strip
      end

      def pull_request_created?
        git_client.create_pull_request(
          repo_name_and_org,
          'master',
          current_branch_name,
          'Automated Bundle Update',
          'Automatic Bundle Update for review'
        )
        true
      end

      def git_client
        @git_client ||= Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
      end

      def git
        @git ||= Git.open(Dir.pwd, log: Logger.new(STDOUT))
      end
    end
  end
end
