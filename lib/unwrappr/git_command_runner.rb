require 'safe_shell'
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

      LOG_OPTIONS = {}.tap do |opts|
        opts[:stdout] = 'unwrappr.log' if ENV['DEBUG']
        opts[:stderr] = 'unwrappr.log' if ENV['DEBUG']
      end

      def git_dir?
        SafeShell.execute?('git', 'rev-parse', '--git-dir', LOG_OPTIONS)
      end

      def branch_created?
        timestamp = Time.now.strftime('%Y%d%m-%H%M').freeze
        SafeShell.execute?(
          'git',
          'checkout',
          '-b',
          "auto_bundle_update_#{timestamp}",
          LOG_OPTIONS
        )
      end

      def git_added_changes?
        SafeShell.execute?('git',
                           'add',
                           '-A',
                           LOG_OPTIONS)
      end

      def git_committed?
        SafeShell.execute?('git',
                           'commit',
                           '-m',
                           'auto bundle update',
                           LOG_OPTIONS)
      end

      def git_pushed?
        SafeShell.execute?('git',
                           'push',
                           'origin',
                           current_branch_name,
                           LOG_OPTIONS)
      end

      def current_branch_name
        SafeShell.execute('git',
                          'rev-parse',
                          '--abbrev-ref',
                          'HEAD',
                          LOG_OPTIONS)
      end

      def repo_name_and_org
        repo = SafeShell.execute('git',
                                 'config',
                                 '--get',
                                 'remote.origin.url',
                                 LOG_OPTIONS)
        # expect "git@github.com:org_name/repo_name.git\n"
        # return org_name/repo_name
        repo.split(':')[1].split('.')[0].strip
      end

      # rubocop:disable Lint/RescueException
      def pull_request_created?
        git_client.create_pull_request(
          repo_name_and_org,
          'master',
          current_branch_name,
          'Automated Bundle Update',
          'Automatic Bundle Update for review'
        )
      rescue Exception
        false
      end
      # rubocop:enable Lint/RescueException

      def git_client
        @git_client ||= Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
      end
    end
  end
end
