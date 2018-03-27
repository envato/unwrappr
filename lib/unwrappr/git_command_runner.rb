require 'safe_shell'

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

      private

      def is_git_dir?
        SafeShell.execute?('git', 'rev-parse --git-dir')
      end

      def branch_created?
        timestamp = Time.now.strftime("%Y%d%m-%H%m")
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
        branch_name = SafeShell.execute('git', 'rev-parse --abbrev-ref HEAD')
        SafeShell.execute?('git', "push origin #{branch_name}")
      end
    end
  end
end
