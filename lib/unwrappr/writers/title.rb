# frozen_string_literal: true

module Unwrappr
  module Writers
    # Add the gem name to the annotation as a heading. If a homepage
    # URI has been determined this heading will link to that page.
    #
    # Implements the `annotation_writer` interface required by the
    # LockFileAnnotator.
    module Title
      class << self
        def write(gem_change, gem_change_info)
          embellished_gem_name = maybe_link(
            gem_change.name,
            gem_change_info.dig(:ruby_gems, 'homepage_uri')
          )
          "### #{embellished_gem_name}\n"
        end

        private

        def maybe_link(text, url)
          if url.nil?
            text
          else
            "[#{text}](#{url})"
          end
        end
      end
    end
  end
end
