# frozen_string_literal: true

require 'forwardable'

module Unwrappr
  # Formats the annotation, documenting the gem change.
  class AnnotationWriter
    extend Forwardable

    def initialize(gem_change, gem_change_info)
      @gem_change = gem_change
      @gem_change_info = gem_change_info
    end

    def write
      <<~MESSAGE
        ### #{name_with_link}

        #{change_description}

        [_#{change_log}, #{source_code}_]
      MESSAGE
    end

    private

    def_delegators :@gem_change,
                   :name, :added?, :removed?, :major?,
                   :minor?, :patch?, :upgrade?, :downgrade?,
                   :base_version, :head_version

    def change_description
      if added? then 'Gem added :snowman:'
      elsif removed? then 'Gem removed :fire:'
      elsif major?
        "**Major** version #{grade}:exclamation: #{version_diff}"
      elsif minor?
        "**Minor** version #{grade}:large_orange_diamond: #{version_diff}"
      elsif patch?
        "**Patch** version #{grade}:small_blue_diamond: #{version_diff}"
      end
    end

    def grade
      if upgrade?
        'upgrade :chart_with_upwards_trend:'
      elsif downgrade?
        'downgrade :chart_with_downwards_trend:'
      end
    end

    def version_diff
      "#{base_version} → #{head_version}"
    end

    def name_with_link
      maybe_link(name, @gem_change_info[:ruby_gems]&.homepage_uri)
    end

    def change_log
      link_or_strikethrough('change-log',
                            @gem_change_info[:ruby_gems]&.changelog_uri)
    end

    def source_code
      link_or_strikethrough('source-code',
                            @gem_change_info[:ruby_gems]&.source_code_uri)
    end

    def maybe_link(text, url)
      if url.nil?
        text
      else
        "[#{text}](#{url})"
      end
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
