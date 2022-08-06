# frozen_string_literal: true

RSpec.describe Unwrappr::Writers::Title do
  describe '.write' do
    subject(:write) { described_class.write(gem_change, gem_change_info) }

    let(:gem_change) { instance_spy(Unwrappr::GemChange, name: 'test-gem') }

    context 'given a gem homepage URI' do
      let(:gem_change_info) { { ruby_gems: ruby_gems } }
      let(:ruby_gems) { { 'homepage_uri' => 'home-uri' } }

      it { should eq "### [test-gem](home-uri)\n" }
    end

    context 'given no gem homepage URI' do
      let(:gem_change_info) { {} }

      it { should eq "### test-gem\n" }
    end
  end
end
