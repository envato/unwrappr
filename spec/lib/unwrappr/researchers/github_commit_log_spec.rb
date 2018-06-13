# frozen_string_literal: true

module Unwrappr
  RSpec.describe GithubCommitLog do
    subject(:annotate) { described_class.annotate(lock_file_content_before, lock_file_content_after) }

    let(:lock_file_content_before) { double('lock_file_content_before') }
    let(:lock_file_content_after) { double('lock_file_content_after') }
    let(:diff) do
      {
        versions: [
          { dependency: :prefixed,       before: 'v1',    after: 'v2'    },
          { dependency: :not_prefixed,   before: '0.0.1', after: '0.0.2' },
          { dependency: :no_source_uri,  before: '1.1',   after: '1.2'   },
          { dependency: :not_github_uri, before: '3',     after: '4'     }
        ]
      }
    end

    before do
      allow(LockFileComparator).to receive(:perform).with(
        lock_file_content_before,
        lock_file_content_after
      ).and_return(diff)

      [
        [:prefixed,      'https://github.com/org/prefixed'],
        [:not_prefixed,  'https://github.com/org/not_prefixed'],
        [:no_source_uri,  nil],
        [:not_github_uri, 'https://not-github.com']
      ].each do |name, uri|
        allow(RubyGems).to receive(:try_get_source_code_uri).with(name).and_return(uri)
      end

      [
        [:prefixed,     'v1',     'v2',     ['message 1', 'message 2']],
        [:prefixed,     'vv1',    'vv2',    []],
        [:not_prefixed, '0.0.1',  '0.0.2',  ['message 3']],
        [:not_prefixed, 'v0.0.1', 'v0.0.2', []]
      ].each do |name, before, after, messages|
        allow(GithubChangelogBuilder).to receive(:build).with(
          repository: "org/#{name}",
          base: before,
          head: after
        ).and_return(messages)
      end
    end

    it 'gets diff from lock file comparator' do
      annotate

      expect(LockFileComparator).to have_received(:perform).with(
        lock_file_content_before,
        lock_file_content_after
      )
    end

    it 'returns annotations' do
      expect(annotate).to eq(
        [
          { 'prefixed'     => ['message 1', 'message 2'] },
          { 'not_prefixed' => ['message 3'] }
        ]
      )
    end
  end
end
