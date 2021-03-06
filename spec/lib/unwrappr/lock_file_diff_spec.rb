# frozen_string_literal: true

module Unwrappr
  RSpec.describe LockFileDiff do
    subject(:lock_file_diff) do
      LockFileDiff.new(
        filename: 'Gemfile.lock',
        base_file: base_file,
        head_file: head_file,
        patch: patch,
        sha: '123'
      )
    end

    let(:patch) { <<~PATCH }
      @@ -1,25 +1,24 @@
      GEM
        remote: https://rubygems.org/
        specs:
      -    diff_lcs (1.3)
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
      -      diff_lcs (>= 1.2.0, < 2.0)
      +    rspec-expectations (3.8.0)
            rspec-support (~> 3.7.0)
      -    rspec-mocks (3.7.0)
      -      diff_lcs (>= 1.2.0, < 2.0)
      +    rspec-mocks (3.6.0)
            rspec-support (~> 3.7.0)
      -    rspec-support (3.7.0)
      +    rspec-support (3.7.1)
           highline (2.0.0)
      -    http_parser.rb (0.6.0)
      -    i18n (1.0.1)
      +    i18n (1.1.0)

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
          diff_lcs (1.3)
          rspec (3.7.0)
            rspec-core (~> 3.7.0)
            rspec-expectations (~> 3.7.0)
            rspec-mocks (~> 3.7.0)
          rspec-core (3.7.1)
            rspec-support (~> 3.7.0)
          rspec-expectations (3.7.0)
            diff_lcs (>= 1.2.0, < 2.0)
            rspec-support (~> 3.7.0)
          rspec-mocks (3.7.0)
            diff_lcs (>= 1.2.0, < 2.0)
            rspec-support (~> 3.7.0)
          rspec-support (3.7.0)
          highline (2.0.0)
          http_parser.rb (0.6.0)
          i18n (1.0.1)

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
          highline (2.0.0)
          i18n (1.1.0)

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
        expect(gem_changes.count).to eq(8)
      end

      describe '1st change' do
        subject(:gem_change) { gem_changes[0] }
        its(:name) { should eq('diff_lcs') }
        it { should be_removed }
        its(:line_number) { should eq 4 }
        its(:base_version) { should eq GemVersion.new('1.3') }
        its(:head_version) { should be_nil }
      end

      describe '2nd change' do
        subject(:gem_change) { gem_changes[1] }
        its(:name) { should eq('http_parser.rb') }
        it { should be_removed }
        its(:line_number) { should eq 26 }
        its(:base_version) { should eq GemVersion.new('0.6.0') }
        its(:head_version) { should be_nil }
      end

      describe '3rd change' do
        subject(:gem_change) { gem_changes[2] }
        its(:name) { should eq('i18n') }
        it { should be_upgrade }
        it { should be_minor }
        its(:line_number) { should eq 28 }
        its(:base_version) { should eq GemVersion.new('1.0.1') }
        its(:head_version) { should eq GemVersion.new('1.1.0') }
      end

      describe '4th change' do
        subject(:gem_change) { gem_changes[3] }
        its(:name) { should eq('pry') }
        it { should be_added }
        its(:line_number) { should eq 6 }
        its(:base_version) { should be_nil }
        its(:head_version) { should eq GemVersion.new('0.11.3') }
      end

      describe '5th change' do
        subject(:gem_change) { gem_changes[4] }
        its(:name) { should eq('rspec') }
        it { should be_upgrade }
        it { should be_major }
        its(:line_number) { should eq 7 }
        its(:base_version) { should eq GemVersion.new('3.7.0') }
        its(:head_version) { should eq GemVersion.new('4.0.0') }
      end

      describe '6th change' do
        subject(:gem_change) { gem_changes[5] }
        its(:name) { should eq('rspec-expectations') }
        it { should be_upgrade }
        it { should be_minor }
        its(:line_number) { should eq 17 }
        its(:base_version) { should eq GemVersion.new('3.7.0') }
        its(:head_version) { should eq GemVersion.new('3.8.0') }
      end

      describe '7th change' do
        subject(:gem_change) { gem_changes[6] }
        its(:name) { should eq('rspec-mocks') }
        it { should be_downgrade }
        it { should be_minor }
        its(:line_number) { should eq 21 }
        its(:base_version) { should eq GemVersion.new('3.7.0') }
        its(:head_version) { should eq GemVersion.new('3.6.0') }
      end

      describe '8th change' do
        subject(:gem_change) { gem_changes[7] }
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
