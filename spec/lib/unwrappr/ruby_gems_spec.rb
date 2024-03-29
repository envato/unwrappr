# frozen_string_literal: true

module Unwrappr
  RSpec.describe RubyGems do
    subject(:gem_info) { described_class.gem_info(gem_name, gem_version) }
    let(:gem_name) { 'gem_name' }
    let(:gem_version) { GemVersion.new('17.53.125') }

    let(:response) { double('faraday_response', status: response_status, body: response_body) }
    let(:response_status) { 200 }
    let(:response_body) { '{}' }

    before do
      allow(Faraday).to receive(:get).and_return(response)
    end

    context 'connectivity' do
      it 'requests rubygems.org API' do
        expect(Faraday).to receive(:get)
          .with('https://rubygems.org/api/v2/rubygems/gem_name/versions/17.53.125.json')

        gem_info
      end
    end

    context 'existing gem' do
      let(:response_body) { '{"key": "value" }' }

      it 'returns provided details' do
        expect(subject['key']).to eql('value')
      end
    end

    context 'unknown gem' do
      let(:response_status) { 404 }
      let(:response_body) { 'Not found' }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end

    context 'runtime error' do
      before do
        allow(Faraday).to receive(:get).and_raise(StandardError)
      end

      it 'is re-raised' do
        expect { subject }.to raise_error(instance_of(StandardError))
      end
    end
  end
end
