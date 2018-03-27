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

      it 'creates the branch' do
        allow(SafeShell).to receive(:execute?)
          .with(
            'git',
            "checkout -b auto_bundle_update_#{expected_timestamp}"
          ).and_return true


        Unwrappr::GitCommandRunner.create_branch!
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
end
