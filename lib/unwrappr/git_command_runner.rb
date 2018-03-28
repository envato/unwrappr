require 'safe_shell'
require 'octokit'

module Unwrappr
  module GitCommandRunner
    class << self
      def create_branch!
        raise 'Not a git working dir' unless is_git_dir?
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

      private

      def is_git_dir?
        SafeShell.execute?('git', 'rev-parse --git-dir')
      end

      def branch_created?
        timestamp = Time.now.strftime('%Y%d%m-%H%m')
        SafeShell.execute?(
          'git',
          "checkout -b auto_bundle_update_#{timestamp}"
        )
      end

      def git_added_changes?
        SafeShell.execute?('git', 'add -A')
      end

      def git_committed?
        SafeShell.execute?('git', 'commit -m "auto bundle update"')
      end

      def git_pushed?
        SafeShell.execute?('git', "push origin #{get_current_branch_name}")
      end

      def get_current_branch_name
        SafeShell.execute('git', 'rev-parse --abbrev-ref HEAD')
      end

      def get_repo_name_and_org
        repo = SafeShell.execute('git', 'config --get remote.origin.url')
        # expect "git@github.com:org_name/repo_name.git\n"
        # return org_name/repo_name
        repo.split(':')[1].split('.')[0].strip
      end

      def pull_request_created?
        git_client.create_pull_request(
          get_repo_name_and_org,
          'master',
          get_current_branch_name,
          'Automated Bundle Update',
          'Automatic Bundle Update for review'
        )
      rescue Exception
        false
      end

      def git_client
        @client ||= Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
      end
    end
  end
end
