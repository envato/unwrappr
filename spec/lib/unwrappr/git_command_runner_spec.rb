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
      end

      it 'does not raise' do
        expect(fake_git).to receive(:branch).with('auto_bundle_update_20170101-1123').and_return(result)
        expect { Unwrappr::GitCommandRunner.create_branch! }.not_to raise_error
      end

      context 'When there is some failiure in creating the branch' do
        it 'raises' do
          expect(fake_git).to receive(:branch).with('auto_bundle_update_20170101-1123').and_raise(Git::GitExecuteError)
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
    let(:github_response) { double('response') }
    let(:octokit_client) { instance_double(Octokit::Client).as_null_object }

    before do
      allow(Octokit::Client).to receive(:new).and_return octokit_client
      allow(fake_git).to receive(:config).with('remote.origin.url').and_return('https://github.com/org/repo')
      allow(fake_git).to receive(:current_branch).and_return('some-new-branch')
    end

    context 'Given a successful octokit pull request request' do
      it 'does not raise' do
        allow(octokit_client).to receive(:create_pull_request).and_return(github_response)
        expect { Unwrappr::GitCommandRunner.make_pull_request! }
          .not_to raise_error
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
end
