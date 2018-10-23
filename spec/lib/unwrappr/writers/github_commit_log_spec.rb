# frozen_string_literal: true

module Unwrappr
  module Writers
    RSpec.describe GithubCommitLog do
      describe '.write' do
        subject(:write) { described_class.write(gem_change, gem_change_info) }

        let(:gem_change) { double }

        context 'given no github comparison' do
          let(:gem_change_info) { {} }

          it { is_expected.to be_nil }
        end

        context 'given a github comparison' do
          let(:gem_change_info) do
            {
              github_comparison: double(
                commits: [
                  double(
                    commit: double(message: 'egg ' * 16),
                    html_url: 'test-commit-html-url',
                    sha: '1234567890'
                  )
                ],
                total_commits: 1,
                html_url: 'test-html-url'
              )
            }
          end

          it { is_expected.to eq <<~MESSAGE }
            <details>
            <summary>Commits</summary>

            A change of **1** commits. See the full changes on [the compare page](test-html-url).

            These are the individual commits:
            - (1234567) [egg egg egg egg egg egg egg egg egg egg egg egg egg egg egg …](test-commit-html-url)


            </details>
          MESSAGE
        end

        context 'given a github comparison with 11 commits' do
          let(:gem_change_info) do
            {
              github_comparison: double(
                commits: Array.new(
                  11,
                  double(
                    commit: double(message: 'test-commit-message'),
                    html_url: 'test-commit-html-url',
                    sha: 'test-commit-sha'
                  )
                ),
                total_commits: 11,
                html_url: 'test-html-url'
              )
            }
          end

          it 'writes only 10 commits' do
            expect(write).to end_with <<~MESSAGE
              These are the first 10 commits:
              - (test-co) [test-commit-message](test-commit-html-url)
              - (test-co) [test-commit-message](test-commit-html-url)
              - (test-co) [test-commit-message](test-commit-html-url)
              - (test-co) [test-commit-message](test-commit-html-url)
              - (test-co) [test-commit-message](test-commit-html-url)
              - (test-co) [test-commit-message](test-commit-html-url)
              - (test-co) [test-commit-message](test-commit-html-url)
              - (test-co) [test-commit-message](test-commit-html-url)
              - (test-co) [test-commit-message](test-commit-html-url)
              - (test-co) [test-commit-message](test-commit-html-url)


              </details>
            MESSAGE
          end
        end
      end
    end
  end
end
