# frozen_string_literal: true

module Unwrappr
  # Responsible for identifying all gem changes between two versions of a
  # Gemfile.lock file.
  class LockFileDiff
    def initialize(filename:, base_file:, head_file:, patch:, sha:)
      @filename = filename
      @base_file = base_file
      @head_file = head_file
      @patch = patch
      @sha = sha
    end

    attr_reader :filename, :sha

    def each_gem_change
      version_changes.each do |change|
        yield GemChange.new(
          name: change[:dependency].to_s,
          base_version: gem_version(change[:before]),
          head_version: gem_version(change[:after]),
          line_number: line_number_for_change(change),
          lock_file_diff: self
        )
      end
    end

    private

    def version_changes
      @version_changes ||=
        LockFileComparator.perform(@base_file, @head_file)[:versions]
    end

    def gem_version(version)
      version && GemVersion.new(version)
    end

    # Obtain the line in the patch that should be annotated
    def line_number_for_change(change)
      # If a gem is removed, use the `-` line (as there is no `+` line).
      # For all other cases use the `+` line.
      type = (change[:after].nil? ? '-' : '+')
      line_numbers[change[:dependency].to_s][type]
    end

    def line_numbers
      return @line_numbers if defined?(@line_numbers)

      @line_numbers = Hash.new { |hash, key| hash[key] = {} }
      @patch.split("\n").each_with_index do |line, line_number|
        gem_name, change_type = extract_gem_and_change_type(line)
        next if gem_name.nil? || change_type.nil?

        @line_numbers[gem_name][change_type] = line_number
      end
      @line_numbers
    end

    def extract_gem_and_change_type(line)
      # We only care about lines like this:
      # '+    websocket-driver (0.6.5)'
      # Careful not to match this (note the wider indent):
      # '+      websocket-extensions (>= 0.1.0)'
      pattern = /^(?<change_type>[+-])    (?<gem_name>\S+) \(\d/
      match = pattern.match(line)
      return match[:gem_name], match[:change_type] unless match.nil?
    end
  end
end
