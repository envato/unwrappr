# frozen_string_literal: true

module Unwrappr
  # Represents the version of a gem. Helps in comparing two versions to
  # identify differences and extracting the major, minor and patch components
  # that make up semantic versioning. https://semver.org/
  class GemVersion
    include Comparable

    def initialize(version_string)
      @version_string = version_string
      @version = Gem::Version.create(version_string)
      @major = segment(0)
      @minor = segment(1)
      @patch = segment(2)
    end

    attr_reader :major, :minor, :patch, :version

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
      @version <=> other.version
    end

    def to_s
      @version_string
    end

    private

    def segment(index)
      segment = @version.canonical_segments[index] || 0
      (segment.is_a?(Numeric) ? segment : nil)
    rescue NoMethodError
      abort(<<~MESSAGE)
        Unwrappr requires RubyGems v2.7.0 or newer.

        To upgrade to the latest RubyGems visit https://rubygems.org/pages/download

      MESSAGE
    end
  end
end
