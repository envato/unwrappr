# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Unwrappr::GitCommandRunner do
  let(:fake_git) { instance_double(Git::Base, :fake_git) }

  before do
    described_class.reset_client
    allow(Git).to receive(:open).and_return(fake_git)
  end

  describe '#create_branch!' do
    subject(:create_branch!) { described_class.create_branch! }

    before { allow(Time).to receive(:now).and_return(Time.parse('2017-01-01 11:23')) }

    context 'Given current directory is not a git repo' do
      before do
        expect(fake_git).to receive(:current_branch).and_raise(Git::GitExecuteError)
      end

      specify do
        expect { create_branch! }.to raise_error(RuntimeError, 'Not a git working dir')
      end
    end

    context 'Given the current directory is a git repo' do
      before do
        expect(fake_git).to receive(:current_branch).and_return('master')
        expect(fake_git).to receive(:checkout).with('origin/master')
      end

      it 'checks out a new branch based on origin/master, with a timestamp' do
        expect(fake_git).to receive(:branch).with('auto_bundle_update_20170101-1123').and_return(fake_git)

        expect(fake_git).to receive(:checkout).with(no_args)

        expect(create_branch!).to be_nil
      end

      context 'When there is some failure in creating the branch' do
        before do
          expect(fake_git).to receive(:branch)
            .with('auto_bundle_update_20170101-1123')
            .and_raise(Git::GitExecuteError)
        end

        specify do
          expect { create_branch! }.to raise_error(RuntimeError, 'failed to create branch')
        end
      end
    end
  end

  describe '#commit_and_push_changes!' do
    subject(:commit_and_push_changes!) { described_class.commit_and_push_changes! }

    context 'Given the git add command fails' do
      before do
        expect(fake_git).to receive(:add).with(all: true).and_raise(Git::GitExecuteError)
      end

      specify do
        expect { commit_and_push_changes! }
          .to raise_error RuntimeError, 'failed to add git changes'
      end
    end

    context 'Given the git add command is successful' do
      before do
        expect(fake_git).to receive(:add).with(all: true).and_return(true)
      end

      context 'When the git commit command fails' do
        before do
          expect(fake_git).to receive(:commit).with('Automatic Bundle Update').and_raise(Git::GitExecuteError)
        end

        specify do
          expect { commit_and_push_changes! }.to raise_error(RuntimeError, 'failed to commit changes')
        end
      end

      context 'Given the git commit command is successful' do
        before do
          expect(fake_git).to receive(:commit).with('Automatic Bundle Update').and_return(true)
        end

        context 'Given the git push command fails' do
          before do
            expect(fake_git).to receive(:current_branch).and_return('branchname')
            expect(fake_git).to receive(:push).with('origin', 'branchname').and_raise(Git::GitExecuteError)
          end

          specify do
            expect { commit_and_push_changes! }
              .to raise_error(RuntimeError, 'failed to push changes')
          end
        end

        context 'Given the git push command is successful' do
          before do
            expect(fake_git).to receive(:current_branch).and_return('branchname')
            expect(fake_git).to receive(:push).with('origin', 'branchname').and_return(true)
          end

          it { is_expected.to be_nil }
        end
      end
    end
  end

  describe '#make_pull_request!' do
    subject(:make_pull_request!) { Unwrappr::GitCommandRunner.make_pull_request! }

    let(:git_url) { 'https://github.com/org/repo.git' }
    let(:octokit_client) { instance_spy(Octokit::Client, :fake_octokit, pull_request_files: []) }

    before do
      allow(fake_git).to receive(:config).with('remote.origin.url').and_return(git_url)
      allow(fake_git).to receive(:current_branch).and_return('some-new-branch')

      allow(Octokit::Client).to receive(:new).and_return octokit_client
    end

    context 'with a token' do
      before do
        allow(ENV).to receive(:fetch).with('GITHUB_TOKEN').and_return('fake tokenz r us')
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
              .with(repo: 'org/repo', pr_number: 34, client: octokit_client)
          end
        end

        context 'When Git URL does not end with .git' do
          let(:git_url) { 'https://github.com/org/repo' }

          it 'annotates the pull request' do
            allow(Unwrappr::LockFileAnnotator).to receive(:annotate_github_pull_request)

            make_pull_request!

            expect(Unwrappr::LockFileAnnotator)
              .to have_received(:annotate_github_pull_request)
              .with(repo: 'org/repo', pr_number: 34, client: octokit_client)
          end
        end
      end

      context 'Given an exception is raised from octokit' do
        before do
          expect(octokit_client).to receive(:create_pull_request)
            .and_raise(Octokit::ClientError)
        end

        specify do
          expect { make_pull_request! }
            .to raise_error(RuntimeError, 'failed to create and annotate pull request')
        end
      end
    end

    context 'without a token' do
      before do
        allow(ENV).to receive(:[]).with('GITHUB_TOKEN').and_return(nil)
      end

      it 'provides useful feedback' do
        expect { make_pull_request! }.to raise_error(RuntimeError, /^Missing environment variable/)
      end
    end
  end

  describe '#show' do
    subject(:show) { described_class.show('HEAD', 'Gemfile.lock') }

    context 'when the proxied git command succeeds' do
      before do
        expect(fake_git).to receive(:show).with('HEAD', 'Gemfile.lock').and_return('content')
      end

      it { is_expected.to eq('content') }
    end

    context 'when the proxied git command fails' do
      before do
        expect(fake_git).to receive(:show).and_raise(Git::GitExecuteError)
      end

      it { is_expected.to be_nil }
    end
  end
end
