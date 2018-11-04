# frozen_string_literal: true

module Unwrappr
  module Researchers
    RSpec.describe SecurityVulnerabilities do
      subject(:security_vulnerabilities) { described_class.new }

      describe '#research' do
        subject(:research) { security_vulnerabilities.research(gem_change, gem_change_info) }

        let(:gem_change) do
          instance_double(
            GemChange,
            name: gem_name,
            base_version: base_version,
            head_version: head_version
          )
        end
        let(:gem_name) { 'test_name' }
        let(:gem_change_info) { { test: 'test' } }
        let(:base_version) { GemVersion.new('1.0.0') }
        let(:head_version) { GemVersion.new('1.1.0') }
        let(:advisories) { [] }
        let(:database) { instance_double(Bundler::Audit::Database) }
        before do
          allow(Bundler::Audit::Database).to receive(:update!)
          allow(Bundler::Audit::Database).to receive(:new).and_return(database)
          allow(database).to receive(:advisories_for).with(gem_name).and_return(advisories)
        end

        it 'updates the advisory database' do
          research
          expect(Bundler::Audit::Database).to have_received(:update!)
        end

        context 'given no advisories for the gem' do
          let(:advisories) { [] }

          it 'reports no vulnerabilities' do
            expect(research).to include(
              security_vulnerabilities: SecurityVulnerabilities::Vulnerabilites.new([], [], [])
            )
          end

          it 'returns the data provided in gem_change_info' do
            expect(research).to include(gem_change_info)
          end
        end

        context 'given base and head versions are not vulnerable' do
          let(:advisories) { [advisory] }
          let(:advisory) { instance_double(Bundler::Audit::Advisory, vulnerable?: false) }

          it 'reports no vulnerabilities' do
            expect(research).to include(
              security_vulnerabilities: SecurityVulnerabilities::Vulnerabilites.new([], [], [])
            )
          end

          it 'returns the data provided in gem_change_info' do
            expect(research).to include(gem_change_info)
          end
        end

        context 'given base version is vulnerable but not head version' do
          let(:advisories) { [advisory] }
          let(:advisory) { instance_double(Bundler::Audit::Advisory) }
          before do
            allow(advisory).to receive(:vulnerable?).with(base_version&.version).and_return(true)
            allow(advisory).to receive(:vulnerable?).with(head_version&.version).and_return(false)
            allow(advisory).to receive(:vulnerable?).with(nil).and_raise(ArgumentError)
          end

          it 'reports patched vulnerabilities' do
            expect(research).to include(
              security_vulnerabilities: SecurityVulnerabilities::Vulnerabilites.new([advisory], [], [])
            )
          end

          it 'returns the data provided in gem_change_info' do
            expect(research).to include(gem_change_info)
          end

          context 'given the head version is nil' do
            let(:head_version) { nil }

            it 'reports patched vulnerabilities' do
              expect(research).to include(
                security_vulnerabilities: SecurityVulnerabilities::Vulnerabilites.new([advisory], [], [])
              )
            end
          end
        end

        context 'given base version is not vulnerable but the head version is' do
          let(:advisories) { [advisory] }
          let(:advisory) { instance_double(Bundler::Audit::Advisory) }
          before do
            allow(advisory).to receive(:vulnerable?).with(base_version&.version).and_return(false)
            allow(advisory).to receive(:vulnerable?).with(head_version&.version).and_return(true)
            allow(advisory).to receive(:vulnerable?).with(nil).and_raise(ArgumentError)
          end

          it 'reports introduced vulnerabilities' do
            expect(research).to include(
              security_vulnerabilities: SecurityVulnerabilities::Vulnerabilites.new([], [advisory], [])
            )
          end

          it 'returns the data provided in gem_change_info' do
            expect(research).to include(gem_change_info)
          end

          context 'given the base version is nil' do
            let(:base_version) { nil }

            it 'reports introduced vulnerabilities' do
              expect(research).to include(
                security_vulnerabilities: SecurityVulnerabilities::Vulnerabilites.new([], [advisory], [])
              )
            end
          end
        end

        context 'given both the base version and the head version are vulnerable' do
          let(:advisories) { [advisory] }
          let(:advisory) { instance_double(Bundler::Audit::Advisory, vulnerable?: true) }

          it 'reports remaining vulnerabilities' do
            expect(research).to include(
              security_vulnerabilities: SecurityVulnerabilities::Vulnerabilites.new([], [], [advisory])
            )
          end

          it 'returns the data provided in gem_change_info' do
            expect(research).to include(gem_change_info)
          end
        end
      end
    end
  end
end
