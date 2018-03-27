require 'clamp'

module Unwrappr
  class CLI < Clamp::Command
    option ["--version", "-v"], :flag, "Show version" do
      puts "unwrappr v#{Unwrappr::VERSION}"
      exit(0)
    end

    option ['-o', '--open'], 'OPEN', 'See whats changed'

    def execute
      puts "Doing the unwrappr thing.."
    end
  end
end
