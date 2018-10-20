# frozen_string_literal: true

module Unwrappr
  module Writers
    RSpec.describe VersionChange do
      describe '.write' do
        subject(:write) { VersionChange.write(gem_change, gem_change_info) }

        let(:gem_change) do
          GemChange.new(name:           'test-gem',
                        head_version:   head_version,
                        base_version:   base_version,
                        line_number:    9870,
                        lock_file_diff: instance_double(LockFileDiff))
        end
        let(:gem_change_info) { {} }

        context 'change from 4.2.0 to 4.2.1' do
          let(:base_version) { GemVersion.new('4.2.0') }
          let(:head_version) { GemVersion.new('4.2.1') }

          it { should eq <<~MESSAGE }
            **Patch** version upgrade :chart_with_upwards_trend::small_blue_diamond: 4.2.0 → 4.2.1
          MESSAGE
        end

        context 'change from 3.9.0 to 4.0.5' do
          let(:base_version) { GemVersion.new('3.9.0') }
          let(:head_version) { GemVersion.new('4.0.5') }

          it { should eq <<~MESSAGE }
            **Major** version upgrade :chart_with_upwards_trend::exclamation: 3.9.0 → 4.0.5
          MESSAGE
        end

        context 'change from 3.9.0 to 3.8.5' do
          let(:base_version) { GemVersion.new('3.9.0') }
          let(:head_version) { GemVersion.new('3.8.5') }

          it { should eq <<~MESSAGE }
            **Minor** version downgrade :chart_with_downwards_trend::large_orange_diamond: 3.9.0 → 3.8.5
          MESSAGE
        end

        context 'gem added at 3.8.5' do
          let(:base_version) { nil }
          let(:head_version) { GemVersion.new('3.8.5') }

          it { should start_with <<~MESSAGE }
            Gem added :snowman:
          MESSAGE
        end

        context 'gem removed at 3.8.5' do
          let(:base_version) { GemVersion.new('3.8.5') }
          let(:head_version) { nil }

          it { should start_with <<~MESSAGE }
            Gem removed :fire:
          MESSAGE
        end
      end
    end
  end
end
