require 'clamp'

module Unwrappr
  class CLI < Clamp::Command
    option ['--version', '-v'], :flag, 'Show version' do
      puts "unwrappr v#{Unwrappr::VERSION}"
      exit(0)
    end

    option ['-o', '--open'], 'OPEN', 'See whats changed'

    def execute
      puts 'Doing the unwrappr thing..'
      # make branch raise if current dir is not a git repo
      # run bundle update
      # commit and push
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
