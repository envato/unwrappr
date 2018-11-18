# frozen_string_literal: true

module Unwrappr
  RSpec.describe LockFileComparator do
    subject(:perform) { described_class.perform(lock_file_content_before, lock_file_content_after) }
    let(:lock_file_content_before) { double('lock_file_content_before') }
    let(:lock_file_content_after) { double('lock_file_content_after') }

    let(:lock_file_before) { double('lock_file_before', specs: specs_before) }
    let(:lock_file_after) { double('lock_file_after', specs: specs_after) }

    let(:specs_before) { [double(name: 'name1', version: 'version1')] }
    let(:specs_after) { [double(name: 'name2', version: 'version2')] }

    let(:specs_versions_comparation_results) { double('specs_versions_comparation_results') }

    before do
      allow(SpecVersionComparator).to receive(:perform).and_return(specs_versions_comparation_results)

      allow(Bundler::LockfileParser).to receive(:new)
        .with(lock_file_content_before)
        .and_return(lock_file_before)
      allow(Bundler::LockfileParser).to receive(:new)
        .with(lock_file_content_after)
        .and_return(lock_file_after)
    end

    it 'calls the comparator with indexed specs versions' do
      expect(SpecVersionComparator).to receive(:perform)
        .with({ name1: 'version1' }, name2: 'version2')

      perform
    end

    it 'returns the difference in specs versions' do
      expected_result = {
        versions: specs_versions_comparation_results
      }

      expect(subject).to eql(expected_result)
    end

    it 'sets the BUNDLE_GEMFILE variable before creating a LockfileParser '\
       'to prevent Bundler looking for a Gemfile on the filesystem '\
       'and raising if it fails to find it (#57)' do
      allow(Bundler::LockfileParser).to receive(:new)
        .with(lock_file_content_before) do
        expect(ENV['BUNDLE_GEMFILE']).to eq('Gemfile')
        lock_file_before
      end
      allow(Bundler::LockfileParser).to receive(:new)
        .with(lock_file_content_after) do
        expect(ENV['BUNDLE_GEMFILE']).to eq('Gemfile')
        lock_file_after
      end

      perform
    end
  end
end
