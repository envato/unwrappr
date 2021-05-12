# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Unwrappr::GitHub::Client do
  let(:lock_files) { ['Gemfile.lock'] }

  before { described_class.reset_client }

  describe '#make_pull_request!' do
    subject(:make_pull_request!) { described_class.make_pull_request!(lock_files) }

    let(:git_url) { 'https://github.com/org/repo.git' }
    let(:octokit_client) { instance_spy(Octokit::Client, :fake_octokit, pull_request_files: []) }

    before do
      allow(Octokit::Client).to receive(:new).and_return octokit_client
      allow(Unwrappr::GitCommandRunner).to receive(:current_branch_name).and_return('some-new-branch')
      allow(Unwrappr::GitCommandRunner).to receive(:remote).and_return(git_url)
    end

    context 'with a token' do
      before do
        allow(ENV).to receive(:fetch).with('GITHUB_TOKEN').and_return('fake tokenz r us')
        allow(octokit_client).to receive_message_chain('repository.default_branch').and_return('main')
      end

      context 'Given a successful Octokit pull request is created' do
        before do
          expect(octokit_client).to receive(:create_pull_request).with(
            'org/repo',
            any_args
          ).and_return(response)
        end

        let(:agent) { Sawyer::Agent.new('http://foo.com/a/') }
        let(:response) { Sawyer::Resource.new(agent, number: 34) }

        context 'When Git URL ends with .git' do
          let(:git_url) { 'git@github.com:org/repo.git' }

          it 'annotates the pull request' do
            allow(Unwrappr::LockFileAnnotator).to receive(:annotate_github_pull_request)

            make_pull_request!

            expect(Unwrappr::LockFileAnnotator)
              .to have_received(:annotate_github_pull_request)
              .with(repo: 'org/repo', pr_number: 34, lock_files: ['Gemfile.lock'], client: octokit_client)
          end
        end

        context 'When Git URL does not end with .git' do
          let(:git_url) { 'https://github.com/org/repo' }

          it 'annotates the pull request' do
            allow(Unwrappr::LockFileAnnotator).to receive(:annotate_github_pull_request)

            make_pull_request!

            expect(Unwrappr::LockFileAnnotator)
              .to have_received(:annotate_github_pull_request)
              .with(repo: 'org/repo', pr_number: 34, lock_files: ['Gemfile.lock'], client: octokit_client)
          end
        end

        context 'When multiple lock files are specified' do
          let(:lock_files) { ['Gemfile.lock', 'Gemfile_next.lock'] }
          let(:git_url) { 'https://github.com/org/repo' }

          it 'annotates the pull request' do
            allow(Unwrappr::LockFileAnnotator).to receive(:annotate_github_pull_request)

            make_pull_request!

            expect(Unwrappr::LockFileAnnotator)
              .to have_received(:annotate_github_pull_request)
              .with(repo: 'org/repo', pr_number: 34, lock_files: ['Gemfile.lock', 'Gemfile_next.lock'],
                    client: octokit_client)
          end
        end
      end

      context 'Given an exception is raised from Octokit' do
        before do
          expect(octokit_client).to receive(:repository)
            .and_raise(Octokit::ClientError)
        end

        specify do
          expect { make_pull_request! }
            .to raise_error(RuntimeError, /^Failed to create and annotate pull request: /)
        end
      end
    end

    context 'without a token' do
      before do
        expect(ENV).to receive(:fetch)
          .with('GITHUB_TOKEN')
          .and_raise(KeyError, 'key not found GITHUB_TOKEN')
      end

      it 'provides useful feedback' do
        expect { make_pull_request! }.to raise_error(RuntimeError, /^Missing environment variable/)
      end
    end
  end
end
