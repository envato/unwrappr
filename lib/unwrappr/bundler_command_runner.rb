require 'safe_shell'

module Unwrappr
  module BundlerCommandRunner
    class << self
      def bundle_update!
        raise 'bundle update failed' unless updated_gems?
      end

      private

      def updated_gems?
        SafeShell.execute?('bundle', 'update')
      end
    end
  end
end