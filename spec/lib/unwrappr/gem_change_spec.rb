# frozen_string_literal: true

module Unwrappr
  RSpec.describe GemChange do
    subject(:gem_change) do
      GemChange.new(
        name: name,
        head_version: head_version,
        base_version: base_version,
        line_number: line_number,
        lock_file_diff: lock_file_diff
      )
    end

    let(:name) { 'test-gem' }
    let(:head_version) { GemVersion.new('4.2.1') }
    let(:base_version) { GemVersion.new('4.2.0') }
    let(:line_number) { 2398 }
    let(:lock_file_diff) { instance_double(LockFileDiff) }

    describe '#added?' do
      context 'given base_version and head_version' do
        let(:base_version) { GemVersion.new('4.2.0') }
        let(:head_version) { GemVersion.new('4.2.1') }
        it { should_not be_added }
      end

      context 'given base_version and no head_version' do
        let(:base_version) { GemVersion.new('4.2.0') }
        let(:head_version) { nil }
        it { should_not be_added }
      end

      context 'given no base_version and a head_version' do
        let(:base_version) { nil }
        let(:head_version) { GemVersion.new('4.2.1') }
        it { should be_added }
      end
    end

    describe '#removed?' do
      context 'given base_version and head_version' do
        let(:base_version) { GemVersion.new('4.2.0') }
        let(:head_version) { GemVersion.new('4.2.1') }
        it { should_not be_removed }
      end

      context 'given base_version and no head_version' do
        let(:base_version) { GemVersion.new('4.2.0') }
        let(:head_version) { nil }
        it { should be_removed }
      end

      context 'given no base_version and a head_version' do
        let(:base_version) { nil }
        let(:head_version) { GemVersion.new('4.2.1') }
        it { should_not be_removed }
      end
    end

    describe '#upgrade?' do
      context 'given base_version 4.2.0 and head_version 4.2.1' do
        let(:base_version) { GemVersion.new('4.2.0') }
        let(:head_version) { GemVersion.new('4.2.1') }
        it { should be_upgrade }
      end

      context 'given base_version 4.2.0 and head_version 4.2.0' do
        let(:base_version) { GemVersion.new('4.2.0') }
        let(:head_version) { GemVersion.new('4.2.0') }
        it { should_not be_upgrade }
      end

      context 'given base_version 4.2.1 and head_version 4.2.0' do
        let(:base_version) { GemVersion.new('4.2.1') }
        let(:head_version) { GemVersion.new('4.2.0') }
        it { should_not be_upgrade }
      end

      context 'given base_version and no head_version' do
        let(:base_version) { GemVersion.new('4.2.0') }
        let(:head_version) { nil }
        it { should_not be_upgrade }
      end

      context 'given no base_version and a head_version' do
        let(:base_version) { nil }
        let(:head_version) { GemVersion.new('4.2.1') }
        it { should_not be_upgrade }
      end
    end

    describe '#downgrade?' do
      context 'given base_version 4.2.0 and head_version 4.2.1' do
        let(:base_version) { GemVersion.new('4.2.0') }
        let(:head_version) { GemVersion.new('4.2.1') }
        it { should_not be_downgrade }
      end

      context 'given base_version 4.2.0 and head_version 4.2.0' do
        let(:base_version) { GemVersion.new('4.2.0') }
        let(:head_version) { GemVersion.new('4.2.0') }
        it { should_not be_downgrade }
      end

      context 'given base_version 4.2.1 and head_version 4.2.0' do
        let(:base_version) { GemVersion.new('4.2.1') }
        let(:head_version) { GemVersion.new('4.2.0') }
        it { should be_downgrade }
      end

      context 'given base_version and no head_version' do
        let(:base_version) { GemVersion.new('4.2.0') }
        let(:head_version) { nil }
        it { should_not be_downgrade }
      end

      context 'given no base_version and a head_version' do
        let(:base_version) { nil }
        let(:head_version) { GemVersion.new('4.2.1') }
        it { should_not be_downgrade }
      end
    end

    describe 'major, minor, patch' do
      context 'given base_version 4.2.0 and head_version 4.2.1' do
        let(:base_version) { GemVersion.new('4.2.0') }
        let(:head_version) { GemVersion.new('4.2.1') }
        it { should_not be_major }
        it { should_not be_minor }
        it { should be_patch }
      end

      context 'given base_version 4.2.5 and head_version 4.3.1' do
        let(:base_version) { GemVersion.new('4.2.5') }
        let(:head_version) { GemVersion.new('4.3.1') }
        it { should_not be_major }
        it { should be_minor }
        it { should_not be_patch }
      end

      context 'given base_version 5.2.5 and head_version 4.3.1' do
        let(:base_version) { GemVersion.new('5.2.5') }
        let(:head_version) { GemVersion.new('4.3.1') }
        it { should be_major }
        it { should_not be_minor }
        it { should_not be_patch }
      end

      context 'given base_version 4.2.0 and head_version 4.2.0' do
        let(:base_version) { GemVersion.new('4.2.0') }
        let(:head_version) { GemVersion.new('4.2.0') }
        it { should_not be_major }
        it { should_not be_minor }
        it { should_not be_patch }
      end

      context 'given base_version 4.2.1 and head_version 4.2.0' do
        let(:base_version) { GemVersion.new('4.2.1') }
        let(:head_version) { GemVersion.new('4.2.0') }
        it { should_not be_major }
        it { should_not be_minor }
        it { should be_patch }
      end

      context 'given base_version and no head_version' do
        let(:base_version) { GemVersion.new('4.2.0') }
        let(:head_version) { nil }
        it { should_not be_major }
        it { should_not be_minor }
        it { should_not be_patch }
      end

      context 'given no base_version and a head_version' do
        let(:base_version) { nil }
        let(:head_version) { GemVersion.new('4.2.1') }
        it { should_not be_major }
        it { should_not be_minor }
        it { should_not be_patch }
      end
    end
  end
end
