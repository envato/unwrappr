# frozen_string_literal: true

require 'bundler/audit'

module Unwrappr
  module Researchers
    # Checks for security vulnerabilities using the Advisory DB
    # https://github.com/rubysec/ruby-advisory-db
    #
    # Implements the `gem_researcher` interface required by the
    # LockFileAnnotator.
    class SecurityVulnerabilities
      Vulnerabilites = Struct.new(:patched, :introduced, :remaining)

      def research(gem_change, gem_change_info)
        gem_change_info.merge(
          security_vulnerabilities: vulnerabilities(gem_change)
        )
      end

      private

      def vulnerabilities(gem)
        advisories = database.advisories_for(gem.name)
        base_advisories = vulnerable_advisories(gem.base_version, advisories)
        head_advisories = vulnerable_advisories(gem.head_version, advisories)
        Vulnerabilites.new(
          base_advisories - head_advisories,
          head_advisories - base_advisories,
          base_advisories & head_advisories
        )
      end

      def database
        return @database if defined?(@database)

        Bundler::Audit::Database.update!(quiet: true)
        @database = Bundler::Audit::Database.new
      end

      def vulnerable_advisories(gem_version, advisories)
        return [] if gem_version.nil?

        advisories.select do |advisory|
          advisory.vulnerable?(gem_version.version)
        end
      end
    end
  end
end
