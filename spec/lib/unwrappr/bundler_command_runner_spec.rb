require 'spec_helper'

RSpec.describe Unwrappr::BundlerCommandRunner do

  describe '#bundle_update!' do
    context 'Given bundle update fails' do

      before do
        allow(SafeShell).to receive(:execute?)
          .with('bundle', 'update').and_return false
      end

      it 'raises' do
        expect { Unwrappr::BundlerCommandRunner.bundle_update! }
          .to raise_error 'bundle update failed'
      end
    end

    context 'Given bundle update succeeds' do

      before do
        allow(SafeShell).to receive(:execute?)
          .with('bundle', 'update').and_return true
      end

      it 'does not raise' do
        expect { Unwrappr::BundlerCommandRunner.bundle_update! }
          .not_to raise_error
      end
    end
  end
end
