# frozen_string_literal: true

module Unwrappr
  module Writers
    # Present reported security vulnerabilities in the gem change annotation.
    #
    # Implements the `annotation_writer` interface required by the
    # LockFileAnnotator.
    class SecurityVulnerabilities
      def self.write(gem_change, gem_change_info)
        new(gem_change, gem_change_info).write
      end

      def initialize(gem_change, gem_change_info)
        @gem_change = gem_change
        @gem_change_info = gem_change_info
      end

      def write
        return nil if vulnerabilities.nil?

        <<~MESSAGE
          #{patched_vulnerabilities}
          #{introduced_vulnerabilities}
          #{remaining_vulnerabilities}
        MESSAGE
      end

      private

      def patched_vulnerabilities
        list_vulnerabilites(
          ':tada: Patched vulnerabilities:',
          vulnerabilities.patched
        )
      end

      def introduced_vulnerabilities
        list_vulnerabilites(
          ':rotating_light::exclamation: Introduced vulnerabilities:',
          vulnerabilities.introduced
        )
      end

      def remaining_vulnerabilities
        list_vulnerabilites(
          ':rotating_light: Remaining vulnerabilities:',
          vulnerabilities.remaining
        )
      end

      def list_vulnerabilites(message, advisories)
        return nil if advisories.empty?

        <<~MESSAGE
          #{message}

          #{advisories.map(&method(:render_vulnerability)).join("\n")}
        MESSAGE
      end

      def render_vulnerability(advisory)
        <<~MESSAGE
          - #{identifier(advisory)}
            **#{advisory.title}**

            #{cvss_v2(advisory)}
            #{link(advisory)}

            #{advisory.description&.gsub("\n", ' ')&.strip}

        MESSAGE
      end

      def identifier(advisory)
        if advisory.cve_id
          "[#{advisory.cve_id}](#{cve_url(advisory.cve_id)})"
        elsif advisory.osvdb_id
          advisory.osvdb_id
        end
      end

      def cve_url(id)
        "https://nvd.nist.gov/vuln/detail/#{id}"
      end

      def cvss_v2(advisory)
        # rubocop:disable Style/GuardClause
        if advisory.cvss_v2
          "CVSS V2: [#{advisory.cvss_v2} #{advisory.criticality}]"\
          "(#{cvss_v2_url(advisory.cve_id)})"
        end
        # rubocop:enable Style/GuardClause
      end

      def cvss_v2_url(id)
        "https://nvd.nist.gov/vuln-metrics/cvss/v2-calculator?name=#{id}"
      end

      def link(advisory)
        "URL: #{advisory.url}" if advisory.url
      end

      def vulnerabilities
        @gem_change_info[:security_vulnerabilities]
      end
    end
  end
end
