require 'safe_shell'

module Unwrappr
  module GitCommandRunner
    class << self
      def create_branch!
        raise 'Not a git working dir' unless is_git_dir?
        raise 'failed to create branch' unless branch_created?
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
    end
  end
end
