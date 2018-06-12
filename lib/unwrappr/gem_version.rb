# frozen_string_literal: true

module Unwrappr
  # Represents the version of a gem. Helps in comparing two versions to
  # identify differences and extracting the major, minor and patch components
  # that make up semantic versioning. https://semver.org/
  class GemVersion
    include Comparable

    def initialize(version_string)
      @version_string = version_string
      @major = match_version(/^(\d+)/)
      @minor = match_version(/^\d+\.(\d+)/)
      @patch = match_version(/^\d+\.\d+\.(\d+)/)
    end

    attr_reader :major, :minor, :patch

    def major_difference?(other)
      (major != other.major)
    end

    def minor_difference?(other)
      (major == other.major) &&
        (minor != other.minor)
    end

    def patch_difference?(other)
      (major == other.major) &&
        (minor == other.minor) &&
        (patch != other.patch)
    end

    def <=>(other)
      if major_difference?(other)
        major <=> other.major
      elsif minor_difference?(other)
        minor <=> other.minor
      elsif patch_difference?(other)
        patch <=> other.patch
      else
        0
      end
    end

    def to_s
      @version_string
    end

    private

    def match_version(pattern)
      match = pattern.match(@version_string)
      match && match[1].to_i
    end
  end
end
