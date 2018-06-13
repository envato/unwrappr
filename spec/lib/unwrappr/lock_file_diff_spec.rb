# frozen_string_literal: true

module Unwrappr
  RSpec.describe LockFileDiff do
    subject(:lock_file_diff) do
      LockFileDiff.new(
        filename:  'Gemfile.lock',
        base_file: base_file,
        head_file: head_file,
        patch:     patch,
        sha:       '123'
      )
    end

    let(:patch) { <<~PATCH }
      @@ -1,25 +1,24 @@
      GEM
        remote: https://rubygems.org/
        specs:
      -    diff-lcs (1.3)
      -    rspec (3.7.0)
      +    pry (0.11.3)
      +    rspec (4.0.0)
            rspec-core (~> 3.7.0)
      -      rspec-expectations (~> 3.7.0)
      -      rspec-mocks (~> 3.7.0)
      +      rspec-expectations (~> 3.8.0)
      +      rspec-mocks (~> 3.6.0)
          rspec-core (3.7.1)
            rspec-support (~> 3.7.0)
      -    rspec-expectations (3.7.0)
      -      diff-lcs (>= 1.2.0, < 2.0)
      +    rspec-expectations (3.8.0)
            rspec-support (~> 3.7.0)
      -    rspec-mocks (3.7.0)
      -      diff-lcs (>= 1.2.0, < 2.0)
      +    rspec-mocks (3.6.0)
            rspec-support (~> 3.7.0)
      -    rspec-support (3.7.0)
      +    rspec-support (3.7.1)

      PLATFORMS
        ruby

      DEPENDENCIES
      +  pry
        rspec

      BUNDLED WITH
    PATCH

    let(:base_file) { <<~BASE_FILE }
      GEM
        remote: https://rubygems.org/
        specs:
          diff-lcs (1.3)
          rspec (3.7.0)
            rspec-core (~> 3.7.0)
            rspec-expectations (~> 3.7.0)
            rspec-mocks (~> 3.7.0)
          rspec-core (3.7.1)
            rspec-support (~> 3.7.0)
          rspec-expectations (3.7.0)
            diff-lcs (>= 1.2.0, < 2.0)
            rspec-support (~> 3.7.0)
          rspec-mocks (3.7.0)
            diff-lcs (>= 1.2.0, < 2.0)
            rspec-support (~> 3.7.0)
          rspec-support (3.7.0)

      PLATFORMS
        ruby

      DEPENDENCIES
        rspec

      BUNDLED WITH
        1.16.2
    BASE_FILE

    let(:head_file) { <<~HEAD_FILE }
      GEM
        remote: https://rubygems.org/
        specs:
          pry (0.11.3)
          rspec (4.0.0)
            rspec-core (~> 3.7.0)
            rspec-expectations (~> 3.8.0)
            rspec-mocks (~> 3.6.0)
          rspec-core (3.7.1)
            rspec-support (~> 3.7.0)
          rspec-expectations (3.8.0)
            rspec-support (~> 3.7.0)
          rspec-mocks (3.6.0)
            rspec-support (~> 3.7.0)
          rspec-support (3.7.1)

      PLATFORMS
        ruby

      DEPENDENCIES
        pry
        rspec

      BUNDLED WITH
        1.16.2
    HEAD_FILE

    describe 'yielded gem changes' do
      subject(:gem_changes) do
        gem_changes = []
        lock_file_diff.each_gem_change { |change| gem_changes << change }
        gem_changes
      end

      it 'yields the correct number of gem changes' do
        expect(gem_changes.count).to eq(6)
      end

      describe '1st' do
        subject(:first_gem_change) { gem_changes[0] }
        its(:name) { should eq('diff-lcs') }
        it { should be_removed }
        its(:line_number) { should eq 4 }
        its(:base_version) { should eq GemVersion.new('1.3') }
        its(:head_version) { should be_nil }
      end

      describe '2nd' do
        subject(:second_gem_change) { gem_changes[1] }
        its(:name) { should eq('pry') }
        it { should be_added }
        its(:line_number) { should eq 6 }
        its(:base_version) { should be_nil }
        its(:head_version) { should eq GemVersion.new('0.11.3') }
      end

      describe '3rd' do
        subject(:third_gem_change) { gem_changes[2] }
        its(:name) { should eq('rspec') }
        it { should be_upgrade }
        it { should be_major }
        its(:line_number) { should eq 7 }
        its(:base_version) { should eq GemVersion.new('3.7.0') }
        its(:head_version) { should eq GemVersion.new('4.0.0') }
      end

      describe '4th' do
        subject(:fourth_gem_change) { gem_changes[3] }
        its(:name) { should eq('rspec-expectations') }
        it { should be_upgrade }
        it { should be_minor }
        its(:line_number) { should eq 17 }
        its(:base_version) { should eq GemVersion.new('3.7.0') }
        its(:head_version) { should eq GemVersion.new('3.8.0') }
      end

      describe '5th' do
        subject(:fifth_gem_change) { gem_changes[4] }
        its(:name) { should eq('rspec-mocks') }
        it { should be_downgrade }
        it { should be_minor }
        its(:line_number) { should eq 21 }
        its(:base_version) { should eq GemVersion.new('3.7.0') }
        its(:head_version) { should eq GemVersion.new('3.6.0') }
      end

      describe '6th' do
        subject(:sixth_gem_change) { gem_changes[5] }
        its(:name) { should eq('rspec-support') }
        it { should be_upgrade }
        it { should be_patch }
        its(:line_number) { should eq 24 }
        its(:base_version) { should eq GemVersion.new('3.7.0') }
        its(:head_version) { should eq GemVersion.new('3.7.1') }
      end
    end
  end
end
