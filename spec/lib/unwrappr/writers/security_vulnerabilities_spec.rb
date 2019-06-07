# frozen_string_literal: true

module Unwrappr
  module Writers
    RSpec.describe SecurityVulnerabilities do
      describe '.write' do
        subject(:write) { described_class.write(gem_change, gem_change_info) }

        let(:gem_change) { double }

        context 'given no security vulnerabilities' do
          let(:gem_change_info) { {} }

          it { is_expected.to be_nil }
        end

        context 'given patched security vulnerabilities' do
          let(:gem_change_info) do
            {
              security_vulnerabilities: double(
                patched: [
                  instance_double(
                    Bundler::Audit::Advisory,
                    cve_id: 'CVE-2018-18476',
                    osvdb_id: nil,
                    title: 'mysql-binuuid-rails allows SQL Injection by removing default string escaping',
                    cvss_v2: 9.9,
                    criticality: 'high',
                    url: 'https://gist.github.com/viraptor/881276ea61e8d56bac6e28454c79f1e6',
                    description: <<~DESC
                      mysql-binuuid-rails 1.1.0 and earlier allows SQL Injection because it removes
                      default string escaping for affected database columns. ActiveRecord does not
                      explicitly escape the Binary data type (Type::Binary::Data) for mysql.
                      mysql-binuuid-rails uses a data type that is derived from the base Binary
                      type, except, it doesn’t convert the value to hex. Instead, it assumes the
                      string value provided is a valid hex string and doesn’t do any checks on it.
                    DESC
                  )
                ],
                introduced: [],
                remaining: []
              )
            }
          end

          it { is_expected.to include <<~MESSAGE }
            :tada: Patched vulnerabilities:

            - [CVE-2018-18476](https://nvd.nist.gov/vuln/detail/CVE-2018-18476)
              **mysql-binuuid-rails allows SQL Injection by removing default string escaping**

              CVSS V2: [9.9 high](https://nvd.nist.gov/vuln-metrics/cvss/v2-calculator?name=CVE-2018-18476)
              URL: https://gist.github.com/viraptor/881276ea61e8d56bac6e28454c79f1e6

              mysql-binuuid-rails 1.1.0 and earlier allows SQL Injection because it removes default string escaping for affected database columns. ActiveRecord does not explicitly escape the Binary data type (Type::Binary::Data) for mysql. mysql-binuuid-rails uses a data type that is derived from the base Binary type, except, it doesn’t convert the value to hex. Instead, it assumes the string value provided is a valid hex string and doesn’t do any checks on it.
          MESSAGE
        end

        context 'given introduced security vulnerabilities' do
          let(:gem_change_info) do
            {
              security_vulnerabilities: double(
                introduced: [
                  instance_double(
                    Bundler::Audit::Advisory,
                    cve_id: nil,
                    osvdb_id: 'legacy_osvdb_id',
                    title: 'mysql-binuuid-rails allows SQL Injection by removing default string escaping',
                    cvss_v2: nil,
                    criticality: nil,
                    url: nil,
                    description: nil
                  )
                ],
                patched: [],
                remaining: []
              )
            }
          end

          it { is_expected.to include <<~MESSAGE }
            :rotating_light::exclamation: Introduced vulnerabilities:

            - legacy_osvdb_id
              **mysql-binuuid-rails allows SQL Injection by removing default string escaping**
          MESSAGE
        end

        context 'given remaining security vulnerabilities' do
          let(:gem_change_info) do
            {
              security_vulnerabilities: double(
                remaining: [
                  instance_double(
                    Bundler::Audit::Advisory,
                    cve_id: nil,
                    osvdb_id: 'legacy_osvdb_id',
                    title: 'mysql-binuuid-rails allows SQL Injection by removing default string escaping',
                    cvss_v2: nil,
                    criticality: nil,
                    url: nil,
                    description: nil
                  )
                ],
                patched: [],
                introduced: []
              )
            }
          end

          it { is_expected.to include <<~MESSAGE }
            :rotating_light: Remaining vulnerabilities:

            - legacy_osvdb_id
              **mysql-binuuid-rails allows SQL Injection by removing default string escaping**
          MESSAGE
        end
      end
    end
  end
end
