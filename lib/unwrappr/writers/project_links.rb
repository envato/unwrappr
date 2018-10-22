# frozen_string_literal: true

module Unwrappr
  module Writers
    # Add links to project documentation as obtained from Rubygems.org.
    # Specifically, the changelog and sourcecode.
    #
    # Implements the `annotation_writer` interface required by the
    # LockFileAnnotator.
    class ProjectLinks
      def self.write(gem_change, gem_change_info)
        new(gem_change, gem_change_info).write
      end

      def initialize(gem_change, gem_change_info)
        @gem_change = gem_change
        @gem_change_info = gem_change_info
      end

      def write
        "[_#{change_log}, #{source_code}_]\n"
      end

      private

      def change_log
        link_or_strikethrough('change-log',
                              @gem_change_info[:ruby_gems]&.changelog_uri)
      end

      def source_code
        link_or_strikethrough('source-code',
                              @gem_change_info[:ruby_gems]&.source_code_uri)
      end

      def link_or_strikethrough(text, url)
        if url.nil?
          "~~#{text}~~"
        else
          "[#{text}](#{url})"
        end
      end
    end
  end
end
