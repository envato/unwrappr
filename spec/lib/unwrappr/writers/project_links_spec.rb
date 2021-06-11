# frozen_string_literal: true

module Unwrappr
  module Writers
    RSpec.describe ProjectLinks do
      describe '.write' do
        subject(:write) { ProjectLinks.write(gem_change, gem_change_info) }

        let(:gem_change) do
          GemChange.new(
            name: 'name',
            base_version: GemVersion.new(1.0),
            head_version: GemVersion.new(2.0),
            line_number: nil,
            lock_file_diff: nil
          )
        end

        context 'given gem change info with urls' do
          let(:gem_change_info) do
            {
              ruby_gems: spy(source_code_uri: 'source-uri',
                             changelog_uri: 'changelog-uri')
            }
          end

          it { should eq <<~MESSAGE }
            [_[change-log](changelog-uri), [source-code](source-uri), [gem-diff](https://my.diffend.io/gems/name/1.0/2.0)_]
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
            [_~~change-log~~, ~~source-code~~, [gem-diff](https://my.diffend.io/gems/name/1.0/2.0)_]
          MESSAGE
        end

        context 'given no gem change info' do
          let(:gem_change_info) { {} }

          it { should eq <<~MESSAGE }
            [_~~change-log~~, ~~source-code~~, ~~gem-diff~~_]
          MESSAGE
        end
      end
    end
  end
end
