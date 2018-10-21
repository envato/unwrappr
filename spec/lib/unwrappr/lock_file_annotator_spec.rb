# frozen_string_literal: true

module Unwrappr
  RSpec.describe Unwrappr::LockFileAnnotator do
    subject(:annotator) do
      described_class.new(
        lock_file_diff_source: lock_file_diff_source,
        annotation_sink: annotation_sink,
        annotation_writer: Writers::Composite.new(
          Writers::Title,
          Writers::VersionChange,
          Writers::ProjectLinks
        ),
        gem_researcher: Researchers::Composite.new(
          Researchers::RubyGemsInfo.new
        )
      )
    end

    describe '#annotate' do
      subject(:annotate) { annotator.annotate }

      context 'given a Gemfile.lock that changes: '\
              'rspec-support 3.7.0 -> 3.7.1' do
        let(:lock_file_diff_source) { instance_double(Github::PrSource) }
        let(:annotation_sink) { instance_spy(Github::PrSink) }
        let(:base_lock_file) { <<~BASE_FILE }
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

        let(:head_lock_file) { <<~HEAD_FILE }
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
              rspec-support (3.7.1)

          PLATFORMS
            ruby

          DEPENDENCIES
            rspec

          BUNDLED WITH
            1.16.2
        HEAD_FILE

        let(:patch) { <<~PATCH }
          @@ -14,7 +14,7 @@ GEM
              rspec-mocks (3.7.0)
                diff-lcs (>= 1.2.0, < 2.0)
                rspec-support (~> 3.7.0)
          -    rspec-support (3.7.0)
          +    rspec-support (3.7.1)

          PLATFORMS
            ruby
        PATCH

        before do
          allow(::Unwrappr::RubyGems).to receive(:gem_info)
            .with('rspec-support')
            .and_return(spy(homepage_uri:     'home-uri',
                            source_code_uri:  'source-uri',
                            changelog_uri:    'changelog-uri'))
          allow(lock_file_diff_source).to receive(:each_file)
            .and_yield(LockFileDiff.new(filename:   'Gemfile.lock',
                                        base_file:  base_lock_file,
                                        head_file:  head_lock_file,
                                        patch:      patch,
                                        sha:        '89ee3f7d'))
        end

        it 'annotates gem changes' do
          annotate
          expect(annotation_sink).to have_received(:annotate_change)
            .with(
              having_attributes(name:         'rspec-support',
                                base_version: GemVersion.new('3.7.0'),
                                head_version: GemVersion.new('3.7.1'),
                                filename:     'Gemfile.lock',
                                sha:          '89ee3f7d',
                                line_number:  5),
              <<~MESSAGE
                ### [rspec-support](home-uri)

                **Patch** version upgrade :chart_with_upwards_trend::small_blue_diamond: 3.7.0 → 3.7.1

                [_[change-log](changelog-uri), [source-code](source-uri)_]
              MESSAGE
            )
        end
      end
    end
  end
end
