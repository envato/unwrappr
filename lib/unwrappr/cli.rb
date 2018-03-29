# frozen_string_literal: true

require 'clamp'

module Unwrappr
  # Entry point for the app
  class CLI < Clamp::Command
    option ['--version', '-v'], :flag, 'Show version' do
      puts "unwrappr v#{Unwrappr::VERSION}"
      exit(0)
    end

    option ['-o', '--open'], 'OPEN', 'See whats changed'

    def execute
      puts 'Doing the unwrappr thing...'
      GitCommandRunner.create_branch!
      BundlerCommandRunner.bundle_update!
      GitCommandRunner.commit_and_push_changes!
      GitCommandRunner.make_pull_request!
      # submit pr
      # 'For each updated gem' do
      #    find git log diffs
      #    get github diff link
      #    figure out where to annotate the pr
      #    annotate the PR
      # end
    end
  end
end
