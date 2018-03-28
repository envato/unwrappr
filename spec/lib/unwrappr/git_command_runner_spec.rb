require 'spec_helper'

RSpec.describe Unwrappr::GitCommandRunner do
  before do
    described_class.reset_client
  end

  describe '#create_branch!' do
    context 'Given current directory is not a git repo' do
      before do
        allow(SafeShell).to receive(:execute?)
          .with('git', 'rev-parse', '--git-dir', {}).and_return false
      end

      it 'raises' do
        expect { Unwrappr::GitCommandRunner.create_branch! }
          .to raise_error 'Not a git working dir'
      end
    end

    context 'Given the current directory is a git repo' do
      let(:now) { Time.now }
      let(:expected_timestamp) { now.strftime('%Y%d%m-%H%m') }

      before do
        allow(SafeShell).to receive(:execute?)
          .with('git', 'rev-parse', '--git-dir', {}).and_return true

        allow(Time).to receive(:now).and_return(now)
      end

      it 'does not raise' do
        allow(SafeShell).to receive(:execute?)
          .with(
            'git',
            'checkout',
            '-b',
            "auto_bundle_update_#{expected_timestamp}",
            {}
          ).and_return true

        expect { Unwrappr::GitCommandRunner.create_branch! }.not_to raise_error
      end

      context 'When there is some failiure in creating the branch' do
        it 'raises' do
          allow(SafeShell).to receive(:execute?)
            .with(
              'git',
              'checkout',
              '-b',
              "auto_bundle_update_#{expected_timestamp}",
              {}
            ).and_return false

          expect { Unwrappr::GitCommandRunner.create_branch! }
            .to raise_error 'failed to create branch'
        end
      end
    end
  end

  describe '#commit_and_push_changes' do
    context 'Given the git add command fails' do
      before do
        allow(SafeShell).to receive(:execute?)
          .with('git', 'add', '-A', {}).and_return false
      end

      it 'raises' do
        expect { Unwrappr::GitCommandRunner.commit_and_push_changes! }
          .to raise_error 'failed to add git changes'
      end
    end

    context 'Given the git add command is successful' do
      before do
        allow(SafeShell).to receive(:execute?)
          .with('git', 'add', '-A', {}).and_return true
      end

      context 'When the git commit command fails' do
        before do
          allow(SafeShell).to receive(:execute?)
            .with('git', 'commit', '-m', 'auto bundle update', {}).and_return false
        end

        it 'raises' do
          expect { Unwrappr::GitCommandRunner.commit_and_push_changes! }
            .to raise_error 'failed to commit changes'
        end
      end

      context 'Given the git commit command is successful' do
        before do
          allow(SafeShell).to receive(:execute?)
            .with('git', 'commit', '-m', 'auto bundle update', {}).and_return true
        end

        context 'Given the git push command fails' do
          before do
            allow(SafeShell).to receive(:execute)
              .with('git', 'rev-parse', '--abbrev-ref', 'HEAD', {})
              .and_return 'foo_bar'

            allow(SafeShell).to receive(:execute?)
              .with('git', 'push', 'origin', 'foo_bar', {}).and_return false
          end

          it 'raises' do
            expect { Unwrappr::GitCommandRunner.commit_and_push_changes! }
              .to raise_error 'failed to push changes'
          end
        end

        context 'Given the git push command is successful' do
          before do
            allow(SafeShell).to receive(:execute)
              .with('git', 'rev-parse', '--abbrev-ref', 'HEAD', {})
              .and_return 'foo_bar'

            allow(SafeShell).to receive(:execute?)
              .with('git', 'push', 'origin', 'foo_bar', {}).and_return true
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
    let(:octokit_client) do
      double('octokit_client')
    end
    before do
      allow(SafeShell).to receive(:execute)
        .with('git', 'rev-parse --abbrev-ref HEAD')
        .and_return 'foo_bar'

      allow(SafeShell).to receive(:execute)
        .with('git', 'config --get remote.origin.url')
        .and_return 'git@github.com:org_name/repo_name.git\n'

      ENV['GITHUB_TOKEN'] = 't0K3Nz'
      allow(Octokit::Client).to receive(:new)
        .with(access_token: 't0K3Nz').and_return octokit_client
    end

    context 'Given a successful octokit pull request request' do
      it 'does not raise' do
        allow(octokit_client).to receive(:create_pull_request)
          .with(
            'org_name/repo_name',
            'master',
            'foo_bar',
            'Automated Bundle Update',
            'Automatic Bundle Update for review'
          ).and_return github_response

        expect { Unwrappr::GitCommandRunner.make_pull_request! }
          .not_to raise_error
      end
    end

    context 'Given an exception is raised from octokit' do
      it 'raises' do
        allow(octokit_client).to receive(:create_pull_request)
          .with(
            'org_name/repo_name',
            'master',
            'foo_bar',
            'Automated Bundle Update',
            'Automatic Bundle Update for review'
          ).and_raise Exception

        expect { Unwrappr::GitCommandRunner.make_pull_request! }
          .to raise_error 'failed to make pull request'
      end
    end
  end
end
