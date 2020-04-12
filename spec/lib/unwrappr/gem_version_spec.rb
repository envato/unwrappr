# frozen_string_literal: true

module Unwrappr
  RSpec.describe GemVersion do
    describe 'major, minor, patch, hotfix' do
      context 'given 4.2.7' do
        subject(:version) { GemVersion.new('4.2.7') }
        its(:major) { should be(4) }
        its(:minor) { should be(2) }
        its(:patch) { should be(7) }
        its(:hotfix) { should be(0) }
      end

      context 'given 5.1' do
        subject(:version) { GemVersion.new('5.1') }
        its(:major) { should be(5) }
        its(:minor) { should be(1) }
        its(:patch) { should be(0) }
        its(:hotfix) { should be(0) }
      end

      context 'given 7' do
        subject(:version) { GemVersion.new('7') }
        its(:major) { should be(7) }
        its(:minor) { should be(0) }
        its(:patch) { should be(0) }
        its(:hotfix) { should be(0) }
      end

      context 'given 12.5.19-beta' do
        subject(:version) { GemVersion.new('12.5.19-beta') }
        its(:major) { should be(12) }
        its(:minor) { should be(5) }
        its(:patch) { should be(19) }
        its(:hotfix) { should be_nil }
      end

      context 'given 1.235-alpha' do
        subject(:version) { GemVersion.new('1.235-alpha') }
        its(:major) { should be(1) }
        its(:minor) { should be(235) }
        its(:patch) { should be_nil }
        its(:hotfix) { should be_nil }
      end
    end

    describe '#<' do
      context '4.2.7' do
        subject(:version) { GemVersion.new('4.2.7') }
        it { should be < GemVersion.new('4.2.8') }
        it { should be < GemVersion.new('4.3.6') }
        it { should be < GemVersion.new('5.1.6') }
        it { should be < GemVersion.new('4.2.7.1') }
      end
    end

    describe '#>' do
      context '4.2.7' do
        subject(:version) { GemVersion.new('4.2.7') }
        it { should be > GemVersion.new('4.2.6') }
        it { should be > GemVersion.new('4.2.6.99') }
        it { should be > GemVersion.new('4.1.8') }
        it { should be > GemVersion.new('3.3.8') }
      end
    end

    describe '#major_difference' do
      context '4.2.7' do
        subject(:version) { GemVersion.new('4.2.7') }
        it { should be_major_difference(GemVersion.new('3.2.7')) }
        it { should be_major_difference(GemVersion.new('5.2.7')) }
        it { should be_major_difference(GemVersion.new('5.3.8')) }
        it { should_not be_major_difference(GemVersion.new('4.2.7')) }
        it { should_not be_major_difference(GemVersion.new('4.2.7.99')) }
        it { should_not be_major_difference(GemVersion.new('4.2.8')) }
        it { should_not be_major_difference(GemVersion.new('4.3.7')) }
      end
    end

    describe '#minor_difference' do
      context '4.2.7' do
        subject(:version) { GemVersion.new('4.2.7') }
        it { should be_minor_difference(GemVersion.new('4.1.7')) }
        it { should be_minor_difference(GemVersion.new('4.3.7')) }
        it { should be_minor_difference(GemVersion.new('4.3.8')) }
        it { should_not be_minor_difference(GemVersion.new('4.2.7')) }
        it { should_not be_minor_difference(GemVersion.new('4.2.7.99')) }
        it { should_not be_minor_difference(GemVersion.new('4.2.8')) }
        it { should_not be_minor_difference(GemVersion.new('5.3.7')) }
      end
    end

    describe '#patch_difference' do
      context '4.2.7' do
        subject(:version) { GemVersion.new('4.2.7') }
        it { should be_patch_difference(GemVersion.new('4.2.6')) }
        it { should be_patch_difference(GemVersion.new('4.2.8')) }
        it { should_not be_patch_difference(GemVersion.new('4.2.7')) }
        it { should_not be_patch_difference(GemVersion.new('4.2.7.99')) }
        it { should_not be_patch_difference(GemVersion.new('4.3.8')) }
        it { should_not be_patch_difference(GemVersion.new('5.2.8')) }
      end
    end

    describe '#hotfix_difference' do
      context '4.2.7.0' do
        subject(:version) { GemVersion.new('4.2.7.0') }
        it { should be_hotfix_difference(GemVersion.new('4.2.7.99')) }
        it { should_not be_hotfix_difference(GemVersion.new('4.2.6')) }
        it { should_not be_hotfix_difference(GemVersion.new('4.2.6.99')) }
        it { should_not be_hotfix_difference(GemVersion.new('4.2.7')) }
        it { should_not be_hotfix_difference(GemVersion.new('4.2.8')) }
        it { should_not be_hotfix_difference(GemVersion.new('4.2.8.99')) }
        it { should_not be_hotfix_difference(GemVersion.new('4.3.8')) }
        it { should_not be_hotfix_difference(GemVersion.new('4.3.8.99')) }
        it { should_not be_hotfix_difference(GemVersion.new('5.2.8')) }
        it { should_not be_hotfix_difference(GemVersion.new('5.2.8.99')) }
      end
    end
  end
end
