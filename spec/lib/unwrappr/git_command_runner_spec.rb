require 'spec_helper'

RSpec.describe Unwrappr::GitCommandRunner do

  describe '#create_branch!' do
    context 'Given current directory is not a git repo' do

      before do
        allow(SafeShell).to receive(:execute?)
          .with('git', 'rev-parse --git-dir').and_return false
      end

      it 'raises' do
        expect { Unwrappr::GitCommandRunner.create_branch! }
          .to raise_error 'Not a git working dir'
      end
    end

    context 'Given the current directory is a git repo' do
      let(:now) { Time.now }
      let(:expected_timestamp) { now.strftime("%Y%d%m-%H%m") }

      before do
        allow(SafeShell).to receive(:execute?)
          .with('git', 'rev-parse --git-dir').and_return true

        allow(Time).to receive(:now).and_return(now)
      end

      it 'does not raise' do
        allow(SafeShell).to receive(:execute?)
          .with(
            'git',
            "checkout -b auto_bundle_update_#{expected_timestamp}"
          ).and_return true

        expect { Unwrappr::GitCommandRunner.create_branch! }.not_to raise_error
      end

      context 'When there is some failiure in creating the branch' do

        it 'raises' do
          allow(SafeShell).to receive(:execute?)
            .with(
              'git',
              "checkout -b auto_bundle_update_#{expected_timestamp}"
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
          .with('git', 'add -A').and_return false
      end

      it 'raises' do
        expect { Unwrappr::GitCommandRunner.commit_and_push_changes! }
          .to raise_error 'failed to add git changes'
      end
    end

    context 'Given the git add command is successful' do
      before do
        allow(SafeShell).to receive(:execute?)
          .with('git', 'add -A').and_return true
      end

      context 'When the git commit command fails' do
        before do
          allow(SafeShell).to receive(:execute?)
            .with('git', 'commit -m "auto bundle update"').and_return false
        end

        it 'raises' do
          expect { Unwrappr::GitCommandRunner.commit_and_push_changes! }
            .to raise_error 'failed to commit changes'
        end
      end

      context 'Given the git commit command is successful' do
        before do
          allow(SafeShell).to receive(:execute?)
            .with('git', 'commit -m "auto bundle update"').and_return true
        end

        context 'Given the git push command fails' do
          before do
            allow(SafeShell).to receive(:execute)
              .with('git', 'rev-parse --abbrev-ref HEAD')
              .and_return 'foo_bar'

            allow(SafeShell).to receive(:execute?)
              .with('git', 'push origin foo_bar').and_return false
          end

          it 'raises' do
            expect { Unwrappr::GitCommandRunner.commit_and_push_changes! }
              .to raise_error 'failed to push changes'
          end
        end

        context 'Given the git push command is successful' do
          before do
            allow(SafeShell).to receive(:execute)
              .with('git', 'rev-parse --abbrev-ref HEAD')
              .and_return 'foo_bar'

            allow(SafeShell).to receive(:execute?)
              .with('git', 'push origin foo_bar').and_return true
          end

          it 'does not raise' do
            expect { Unwrappr::GitCommandRunner.commit_and_push_changes! }
              .not_to raise_error
          end
        end
      end
    end
  end
end
