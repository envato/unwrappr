require 'safe_shell'

module Unwrappr
  # Runs the bundle command. No surprises.
  module BundlerCommandRunner
    class << self
      def bundle_update!
        raise 'bundle update failed' unless updated_gems?
      end

      private

      def updated_gems?
        SafeShell.execute?(
          'bundle',
          'update',
          stdout: 'stdout.txt',
          stderr: 'error.txt'
        )
      end
    end
  end
end
