# frozen_string_literal: true

module Unwrappr
  module Researchers
    RSpec.describe GithubRepo do
      subject(:github_repo) { described_class.new }

      describe '#research' do
        subject(:research) { github_repo.research(gem_change, gem_change_info) }

        let(:gem_change) { instance_double(GemChange) }
        [
          [nil, nil, nil],
          ['', '', nil],
          [' ', ' ', nil],
          [nil, 'https://github.com/envato/stack_master/tree', 'envato/stack_master'],
          ['', 'https://github.com/envato/stack_master/tree', 'envato/stack_master'],
          [' ', 'https://github.com/envato/stack_master/tree', 'envato/stack_master'],
          ['https://bitbucket.org/envato/unwrappr/tree', 'https://github.com/envato/stack_master/tree', 'envato/stack_master'],
          ['https://github.com/envato/unwrappr/tree', 'https://github.com/envato/stack_master/tree', 'envato/unwrappr'],
          [nil, 'https://github.com/rubymem/bundler-leak#readme', 'rubymem/bundler-leak'],
        ].each do |source_code_uri, homepage_uri, expected_repo|
          context "given source_code_uri: #{source_code_uri.inspect}, homepage_uri: #{homepage_uri.inspect}" do
            let(:gem_change_info) do
              {
                ruby_gems: {
                  source_code_uri: source_code_uri,
                  homepage_uri: homepage_uri
                }
              }
            end

            it "sets the github_repo to #{expected_repo.inspect}" do
              expect(research[:github_repo]).to eq(expected_repo)
            end

            it 'returns the data provided in gem_change_info' do
              expect(research).to include(gem_change_info)
            end
          end
        end

        context 'given no ruby_gems info' do
          let(:gem_change_info) { { ruby_gems: nil, something_else: 'xyz' } }

          it 'sets the github_repo to nil' do
            expect(research[:github_repo]).to be_nil
          end

          it 'returns the data provided in gem_change_info' do
            expect(research).to include(gem_change_info)
          end
        end
      end
    end
  end
end
