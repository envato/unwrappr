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
        "[_#{change_log}, #{source_code}, #{gem_diff}_]\n"
      end

      private

      def change_log
        link_or_strikethrough('change-log', ruby_gems_info('changelog_uri'))
      end

      def source_code
        link_or_strikethrough('source-code', ruby_gems_info('source_code_uri'))
      end

      GEM_DIFF_URL_TEMPLATE = 'https://my.diffend.io/gems/%s/%s/%s'
      private_constant :GEM_DIFF_URL_TEMPLATE

      def gem_diff
        if !ruby_gems_info.nil? && !@gem_change.added? && !@gem_change.removed?
          gem_diff_url = format(GEM_DIFF_URL_TEMPLATE,
                                @gem_change.name,
                                @gem_change.base_version.to_s,
                                @gem_change.head_version.to_s)
        end
        link_or_strikethrough('gem-diff', gem_diff_url)
      end

      def ruby_gems_info(*args)
        return @gem_change_info[:ruby_gems] if args.empty?

        @gem_change_info.dig(:ruby_gems, *args)
      end

      def link_or_strikethrough(text, url)
        if url.nil? || url.empty?
          "~~#{text}~~"
        else
          "[#{text}](#{url})"
        end
      end
    end
  end
end
