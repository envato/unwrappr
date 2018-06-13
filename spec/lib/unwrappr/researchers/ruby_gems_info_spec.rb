# frozen_string_literal: true

module Unwrappr
  RSpec.describe Researchers::RubyGemsInfo do
    subject(:ruby_gems_info) { Researchers::RubyGemsInfo.new }

    describe 'research' do
      subject(:research) do
        ruby_gems_info.research(gem_change, gem_change_info)
      end

      let(:gem_change) { instance_double(GemChange, name: gem_name) }
      let(:gem_change_info) { { something_existing: 'random' } }
      let(:gem_name) { 'test-name' }
      let(:info) { 'this-is-the-info-from-rubygems' }

      before do
        allow(::Unwrappr::RubyGems).to receive(:gem_info).and_return(info)
      end

      it 'queries RubyGems using the gem name' do
        research
        expect(::Unwrappr::RubyGems).to have_received(:gem_info).with(gem_name)
      end

      it 'returns the data from RubyGems' do
        expect(research).to include(ruby_gems: info)
      end

      it 'returns the data provided in gem_change_info' do
        expect(research).to include(gem_change_info)
      end
    end
  end
end
