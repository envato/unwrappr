# frozen_string_literal: true

module Unwrappr
  module Writers
    # Delegate to many writers and combine their produced annotations into one.
    #
    # Implements the `annotation_writer` interface required by the
    # LockFileAnnotator.
    class Composite
      def initialize(*writers)
        @writers = writers
      end

      def write(gem_change, gem_change_info)
        @writers.map do |writer|
          writer.write(gem_change, gem_change_info)
        end.compact.join("\n")
      end
    end
  end
end
