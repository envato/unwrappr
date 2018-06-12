# frozen_string_literal: true

module Unwrappr
  RSpec.describe AnnotationWriter do
    subject(:annotation_writer) do
      AnnotationWriter.new(gem_change, gem_change_info)
    end

    let(:gem_change) do
      GemChange.new(name:           gem_name,
                    head_version:   head_version,
                    base_version:   base_version,
                    line_number:    9870,
                    lock_file_diff: lock_file_diff)
    end
    let(:gem_change_info) { {} }
    let(:lock_file_diff) { instance_double(LockFileDiff) }

    describe '#write' do
      subject(:message) { annotation_writer.write }

      context 'given gem change info with urls' do
        let(:gem_change_info) { { ruby_gems: ruby_gems } }
        let(:ruby_gems) do
          spy(homepage_uri:     'home-uri',
              source_code_uri:  'source-uri',
              changelog_uri:    'changelog-uri')
        end

        context 'test-gem goes from 4.2.0 to 4.2.1' do
          let(:gem_name) { 'test-gem' }
          let(:base_version) { GemVersion.new('4.2.0') }
          let(:head_version) { GemVersion.new('4.2.1') }

          it { should eq <<~MESSAGE }
            ### [test-gem](home-uri)

            **Patch** version upgrade :chart_with_upwards_trend::small_blue_diamond: 4.2.0 → 4.2.1

            [_[change-log](changelog-uri), [source-code](source-uri)_]
          MESSAGE
        end
      end
      context 'given no gem change info' do
        context 'test-gem goes from 4.2.0 to 4.2.1' do
          let(:gem_name) { 'test-gem' }
          let(:base_version) { GemVersion.new('4.2.0') }
          let(:head_version) { GemVersion.new('4.2.1') }

          it { should eq <<~MESSAGE }
            ### test-gem

            **Patch** version upgrade :chart_with_upwards_trend::small_blue_diamond: 4.2.0 → 4.2.1

            [_~~change-log~~, ~~source-code~~_]
          MESSAGE
        end

        context 'thingy goes from 3.9.0 to 4.0.5' do
          let(:gem_name) { 'thingy' }
          let(:base_version) { GemVersion.new('3.9.0') }
          let(:head_version) { GemVersion.new('4.0.5') }

          it { should eq <<~MESSAGE }
            ### thingy

            **Major** version upgrade :chart_with_upwards_trend::exclamation: 3.9.0 → 4.0.5

            [_~~change-log~~, ~~source-code~~_]
          MESSAGE
        end

        context 'whatsit goes from 3.9.0 to 3.8.5' do
          let(:gem_name) { 'whatsit' }
          let(:base_version) { GemVersion.new('3.9.0') }
          let(:head_version) { GemVersion.new('3.8.5') }

          it { should eq <<~MESSAGE }
            ### whatsit

            **Minor** version downgrade :chart_with_downwards_trend::large_orange_diamond: 3.9.0 → 3.8.5

            [_~~change-log~~, ~~source-code~~_]
          MESSAGE
        end

        context 'test-gem added at 3.8.5' do
          let(:gem_name) { 'test-gem' }
          let(:base_version) { nil }
          let(:head_version) { GemVersion.new('3.8.5') }

          it { should eq <<~MESSAGE }
            ### test-gem

            Gem added :dizzy:

            [_~~change-log~~, ~~source-code~~_]
          MESSAGE
        end

        context 'test-gem removed at 3.8.5' do
          let(:gem_name) { 'test-gem' }
          let(:base_version) { GemVersion.new('3.8.5') }
          let(:head_version) { nil }

          it { should eq <<~MESSAGE }
            ### test-gem

            Gem removed :fire:

            [_~~change-log~~, ~~source-code~~_]
          MESSAGE
        end
      end
    end
  end
end
