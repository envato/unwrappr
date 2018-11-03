# frozen_string_literal: true

module Unwrappr
  module Researchers
    RSpec.describe GithubRepo do
      subject(:github_repo) { described_class.new }

      describe '#research' do
        subject(:research) { github_repo.research(gem_change, gem_change_info) }

        let(:gem_change) { instance_double(GemChange) }
        let(:gem_change_info) { { ruby_gems: info } }
        let(:info) { spy(:ruby_gem_info, source_code_uri: source_code_uri) }

        context 'given a non Github source code URI' do
          let(:source_code_uri) { 'https://bitbucket.org/envato/unwrappr/tree' }

          it "doesn't add the Github repo" do
            expect(research).to_not include(:github_repo)
          end

          it 'returns the data provided in gem_change_info' do
            expect(research).to include(gem_change_info)
          end
        end

        context 'given a Github source code URI' do
          let(:source_code_uri) { 'https://github.com/envato/unwrappr/tree' }

          it 'extracts the repo' do
            expect(research).to include(github_repo: 'envato/unwrappr')
          end

          it 'returns the data provided in gem_change_info' do
            expect(research).to include(gem_change_info)
          end
        end
      end
    end
  end
end
