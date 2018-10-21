# frozen_string_literal: true

module Unwrappr
  module Researchers
    RSpec.describe GithubComparison do
      subject(:github_comparison) { GithubComparison.new(client) }

      let(:client) { instance_double(Octokit::Client) }

      describe '#research' do
        subject(:research) { github_comparison.research(gem_change, gem_change_info) }

        let(:gem_change) do
          instance_double(
            GemChange,
            base_version: base_version,
            head_version: head_version
          )
        end
        let(:gem_change_info) { { ruby_gems: info } }
        let(:info) { spy(:ruby_gem_info, source_code_uri: source_code_uri) }
        let(:base_version) { GemVersion.new('1.0.0') }
        let(:head_version) { GemVersion.new('1.1.0') }
        let(:response) { double }

        context 'given a non Github source code URI' do
          let(:source_code_uri) { 'https://bitbucket.org/envato/unwrappr/tree' }

          it "doesn't add data from Github" do
            expect(research).to_not include(:github_comparison)
          end

          it 'returns the data provided in gem_change_info' do
            expect(research).to include(gem_change_info)
          end
        end

        context 'given a Github source code URI' do
          let(:source_code_uri) { 'https://github.com/envato/unwrappr/tree' }

          context 'given the repo has "vx.x.x" tags' do
            before do
              allow(client).to receive(:compare)
                .with('envato/unwrappr', 'v1.0.0', 'v1.1.0')
                .and_return(response)
              allow(client).to receive(:compare)
                .with('envato/unwrappr', '1.0.0', '1.1.0')
                .and_return(nil)
            end

            it 'returns the data from Github' do
              expect(research).to include(github_comparison: response)
            end

            it 'returns the data provided in gem_change_info' do
              expect(research).to include(gem_change_info)
            end
          end

          context 'given the repo has "x.x.x" tags' do
            before do
              allow(client).to receive(:compare)
                .with('envato/unwrappr', 'v1.0.0', 'v1.1.0')
                .and_return(nil)
              allow(client).to receive(:compare)
                .with('envato/unwrappr', '1.0.0', '1.1.0')
                .and_return(response)
            end

            it 'returns the data from Github' do
              expect(research).to include(github_comparison: response)
            end

            it 'returns the data provided in gem_change_info' do
              expect(research).to include(gem_change_info)
            end
          end
        end
      end
    end
  end
end
