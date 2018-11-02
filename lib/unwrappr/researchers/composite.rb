# frozen_string_literal: true

module Unwrappr
  module Researchers
    # Delegate to many researchers, collecting and returning their findings.
    #
    # Implements the `gem_researcher` interface required by the
    # LockFileAnnotator.
    class Composite
      def initialize(*researchers)
        @researchers = researchers
      end

      def research(gem_change, gem_change_info)
        @researchers.reduce(gem_change_info) do |info, researcher|
          researcher.research(gem_change, info)
        end
      end
    end
  end
end
