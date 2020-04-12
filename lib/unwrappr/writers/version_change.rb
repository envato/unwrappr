# frozen_string_literal: true

module Unwrappr
  module Writers
    # Describe the version change. Is it an upgrade to a later version, or a
    # downgrade to an older version? Is it a major, minor or patch version
    # change?
    #
    # Implements the `annotation_writer` interface required by the
    # LockFileAnnotator.
    class VersionChange
      extend Forwardable

      def self.write(gem_change, gem_change_info)
        new(gem_change, gem_change_info).write
      end

      def initialize(gem_change, gem_change_info)
        @gem_change = gem_change
        @gem_change_info = gem_change_info
      end

      def write
        "#{change_description}\n"
      end

      private

      def_delegators(:@gem_change,
                     :added?, :removed?, :major?, :minor?, :patch?, :hotfix?,
                     :upgrade?, :downgrade?, :base_version, :head_version)

      def change_description
        if added? then 'Gem added :snowman:'
        elsif removed? then 'Gem removed :fire:'
        elsif major?
          "**Major** version #{grade}:exclamation: #{version_diff}"
        elsif minor?
          "**Minor** version #{grade}:large_orange_diamond: #{version_diff}"
        elsif patch?
          "**Patch** version #{grade}:small_blue_diamond: #{version_diff}"
        elsif hotfix?
          "**Hotfix** version #{grade}:small_red_triangle: #{version_diff}"
        end
      end

      def grade
        if upgrade?
          'upgrade :chart_with_upwards_trend:'
        elsif downgrade?
          'downgrade :chart_with_downwards_trend::exclamation:'
        end
      end

      def version_diff
        "#{base_version} → #{head_version}"
      end
    end
  end
end
