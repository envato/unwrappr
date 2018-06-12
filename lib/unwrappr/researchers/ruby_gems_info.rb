# frozen_string_literal: true

module Unwrappr
  module Researchers
    # Implements the GemResearcher interface required by the
    # LockFileAnnotator.
    #
    # Obtains information about the gem from https://rubygems.org/
    class RubyGemsInfo
      def research(gem_change, gem_change_info)
        gem_change_info.merge(
          ruby_gems: ::Unwrappr::RubyGems.gem_info(gem_change.name)
        )
      end
    end
  end
end
