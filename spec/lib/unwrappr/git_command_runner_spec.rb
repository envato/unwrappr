# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Unwrappr::GitCommandRunner do
  let!(:fake_git) { instance_double(Git::Base) }

  before do
    described_class.reset_client
    allow(Git).to receive(:open).and_return(fake_git)
  end

  describe '#create_branch!' do
    context 'Given current directory is not a git repo' do
      before do
        expect(fake_git).to receive(:current_branch).and_raise(Git::GitExecuteError)
      end

      it 'raises' do
        expect { Unwrappr::GitCommandRunner.create_branch! }
          .to raise_error 'Not a git working dir'
      end
    end

    context 'Given the current directory is a git repo' do
      let(:result) { double('Branch', checkout: true) }
      before do
        allow(Time).to receive(:now).and_return(Time.parse('2017-01-01 11:23'))
        expect(fake_git).to receive(:current_branch).and_return('master')
        expect(fake_git).to receive(:checkout).with('origin/master')
      end

      it 'does not raise' do
        expect(fake_git).to receive(:branch)
          .with('auto_bundle_update_20170101-1123')
          .and_return(result)
        expect { Unwrappr::GitCommandRunner.create_branch! }.not_to raise_error
      end

      context 'When there is some failiure in creating the branch' do
        it 'raises' do
          expect(fake_git).to receive(:branch)
            .with('auto_bundle_update_20170101-1123')
            .and_raise(Git::GitExecuteError)
          expect { Unwrappr::GitCommandRunner.create_branch! }
            .to raise_error 'failed to create branch'
        end
      end
    end
  end

  describe '#commit_and_push_changes' do
    before do
      allow(fake_git).to receive(:current_branch).and_return('some-new-branch')
    end

    context 'Given the git add command fails' do
      before do
        expect(fake_git).to receive(:add).and_raise(Git::GitExecuteError)
      end

      it 'raises' do
        expect { Unwrappr::GitCommandRunner.commit_and_push_changes! }
          .to raise_error 'failed to add git changes'
      end
    end

    context 'Given the git add command is successful' do
      before do
        expect(fake_git).to receive(:add).and_return(true)
      end

      context 'When the git commit command fails' do
        before do
          expect(fake_git).to receive(:commit).and_raise(Git::GitExecuteError)
        end

        it 'raises' do
          expect { Unwrappr::GitCommandRunner.commit_and_push_changes! }
            .to raise_error 'failed to commit changes'
        end
      end

      context 'Given the git commit command is successful' do
        before do
          expect(fake_git).to receive(:commit).and_return(true)
        end

        context 'Given the git push command fails' do
          before do
            expect(fake_git).to receive(:push).and_raise(Git::GitExecuteError)
          end

          it 'raises' do
            expect { Unwrappr::GitCommandRunner.commit_and_push_changes! }
              .to raise_error 'failed to push changes'
          end
        end

        context 'Given the git push command is successful' do
          before do
            expect(fake_git).to receive(:push).and_return(true)
          end

          it 'does not raise' do
            expect { Unwrappr::GitCommandRunner.commit_and_push_changes! }
              .not_to raise_error
          end
        end
      end
    end
  end

  describe '#make_pull_request!' do
    subject(:make_pull_request!) { Unwrappr::GitCommandRunner.make_pull_request! }
    let(:github_response) { double('response') }
    let(:octokit_client) { instance_double(Octokit::Client).as_null_object }
    let(:git_url) { 'https://github.com/org/repo' }

    before do
      allow(Octokit::Client).to receive(:new).and_return octokit_client
      allow(fake_git).to receive(:config).with('remote.origin.url').and_return(git_url)
      allow(fake_git).to receive(:current_branch).and_return('some-new-branch')
      allow(fake_git).to receive(:show).and_return('some text')
    end

    context 'Given a successful octokit pull request is created' do
      before do
        allow(octokit_client).to receive(:create_pull_request).and_return(github_response)
      end

      context 'When Git URL ends with .git' do
        let(:git_url) { 'git@github.com:org/repo.git' }

        it 'creates a pull request in the repo' do
          make_pull_request!
          expect(octokit_client).to have_received(:create_pull_request).with(
            'org/repo',
            any_args
          )
        end

        it 'does not raise any error' do
          expect { make_pull_request! }
            .not_to raise_error
        end
      end

      context 'When Git URL does not end with .git' do
        let(:git_url) { 'https://github.com/org/repo' }

        it 'creates a pull request in the repo' do
          make_pull_request!
          expect(octokit_client).to have_received(:create_pull_request).with(
            'org/repo',
            any_args
          )
        end

        it 'does not raise any error' do
          expect { make_pull_request! }
            .not_to raise_error
        end
      end
    end

    context 'Given an exception is raised from octokit' do
      it 'raises' do
        expect(octokit_client).to receive(:create_pull_request)
          .and_raise Octokit::ClientError

        expect { Unwrappr::GitCommandRunner.make_pull_request! }
          .to raise_error 'failed to make pull request'
      end
    end
  end

  describe '#show' do
    subject(:show) { Unwrappr::GitCommandRunner.show('HEAD', 'Gemfile.lock') }

    before do
      allow(fake_git).to receive(:show)
    end

    it 'calls git.show using proper parameters' do
      expect(fake_git).to receive(:show).with('HEAD', 'Gemfile.lock')

      show
    end

    it 'returns the result' do
      allow(fake_git).to receive(:show).and_return('content')

      expect(show).to eq('content')
    end

    it 'handles client exceptions' do
      allow(fake_git).to receive(:show).and_raise(Git::GitExecuteError)

      expect(show).to be_nil
    end
  end
end
