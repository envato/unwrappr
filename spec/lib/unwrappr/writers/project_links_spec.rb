# frozen_string_literal: true

module Unwrappr
  module Writers
    RSpec.describe ProjectLinks do
      describe '.write' do
        subject(:write) { ProjectLinks.write(gem_change, gem_change_info) }

        let(:gem_change) { instance_double(GemChange) }

        context 'given gem change info with urls' do
          let(:gem_change_info) do
            {
              ruby_gems: spy(source_code_uri: 'source-uri',
                             changelog_uri:   'changelog-uri')
            }
          end

          it { should eq <<~MESSAGE }
            [_[change-log](changelog-uri), [source-code](source-uri)_]
          MESSAGE
        end

        context 'given gem change info with missing urls' do
          let(:gem_change_info) do
            {
              ruby_gems: spy(source_code_uri: '',
                             changelog_uri: '')
            }
          end

          it { is_expected.to eq <<~MESSAGE }
            [_~~change-log~~, ~~source-code~~_]
          MESSAGE
        end

        context 'given no gem change info' do
          let(:gem_change_info) { {} }

          it { should eq <<~MESSAGE }
            [_~~change-log~~, ~~source-code~~_]
          MESSAGE
        end
      end
    end
  end
end
