# frozen_string_literal: true

require 'forwardable'

module Unwrappr
  # Represents a gem change in a Gemfile.lock diff.
  class GemChange
    extend Forwardable

    def initialize(
      name:, head_version:, base_version:, line_number:, lock_file_diff:
    )
      @name = name
      @head_version = head_version
      @base_version = base_version
      @line_number = line_number
      @lock_file_diff = lock_file_diff
    end

    attr_reader :name, :head_version, :base_version, :line_number
    def_delegators :@lock_file_diff, :filename, :sha

    def added?
      (head_version && base_version.nil?)
    end

    def removed?
      (base_version && head_version.nil?)
    end

    def major?
      head_version && base_version &&
        head_version.major_difference?(base_version)
    end

    def minor?
      head_version && base_version &&
        head_version.minor_difference?(base_version)
    end

    def patch?
      head_version && base_version &&
        head_version.patch_difference?(base_version)
    end

    def upgrade?
      head_version && base_version && (head_version > base_version)
    end

    def downgrade?
      head_version && base_version && (head_version < base_version)
    end
  end
end
