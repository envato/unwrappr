# frozen_string_literal: true

module Unwrappr
  RSpec.describe Github::PrSource do
    subject(:pr_source) { Github::PrSource.new(repo, pr_number, lock_files, client) }

    let(:repo) { 'envato/unwrappr' }
    let(:pr_number) { 223 }
    let(:lock_files) { ['Gemfile.lock'] }
    let(:client) { instance_double(Octokit::Client) }
    let(:pr_files) do
      [
        double(filename: 'my/Gemfile.lock', patch: 'my-gem-patch'),
        double(filename: 'not.a.gem.file.lock', patch: 'another-patch')
      ]
    end
    let(:pr) { double }
    let(:content1) { double(content: 'encoded-content-1') }
    let(:content2) { double(content: 'encoded-content-2') }
    let(:lock_file_diff) { double }

    before do
      allow(LockFileDiff).to receive(:new)
                               .with(hash_including(filename: 'my/Gemfile.lock'))
                               .and_return(double(filename: 'my/Gemfile.lock'))
      allow(Base64).to receive(:decode64)
        .with('encoded-content-1')
        .and_return('content-1')
      allow(Base64).to receive(:decode64)
        .with('encoded-content-2')
        .and_return('content-2')

      allow(client).to receive(:pull_request_files)
        .with(repo, pr_number)
        .and_return(pr_files)
      allow(client).to receive(:pull_request)
        .with(repo, pr_number)
        .and_return(pr)
      allow(client).to receive(:contents)
        .with(repo, path: 'my/Gemfile.lock', ref: 'base-sha')
        .and_return(content1)
      allow(client).to receive(:contents)
        .with(repo, path: 'my/Gemfile.lock', ref: 'head-sha')
        .and_return(content2)

      allow(pr).to receive_message_chain(:base, :sha)
        .and_return('base-sha')
      allow(pr).to receive_message_chain(:head, :sha)
        .and_return('head-sha')
    end

    describe '#each_file' do
      subject(:files) do
        files = []
        pr_source.each_file { |lock_diff| files << lock_diff }
        files
      end

      it 'identifies the Gemfile.lock' do
        expect(files.map(&:filename)).to eq(['my/Gemfile.lock'])
      end

      it 'produces a LockFileDiff with the expected attributes' do
        files
        expect(LockFileDiff).to have_received(:new)
          .with(filename: 'my/Gemfile.lock',
                base_file: 'content-1',
                head_file: 'content-2',
                patch: 'my-gem-patch',
                sha: 'head-sha')
      end

      context 'when multiple gem lock files are specified' do
        let(:lock_files) { ['Gemfile.lock', 'Gemfile_next.lock'] }
        let(:pr_files) do
          [
            double(filename: 'my/Gemfile.lock', patch: 'my-gem-patch'),
            double(filename: 'Gemfile_next.lock', patch: 'next-gem-patch'),
            double(filename: 'not.a.gem.file.lock', patch: 'another-patch')
          ]
        end

        before do
          allow(LockFileDiff).to receive(:new)
                                   .with(hash_including(filename: 'Gemfile_next.lock'))
                                   .and_return(double(filename: 'Gemfile_next.lock'))
          allow(client).to receive(:contents)
                             .with(repo, path: 'Gemfile_next.lock', ref: 'base-sha')
                             .and_return(content1)
          allow(client).to receive(:contents)
                             .with(repo, path: 'Gemfile_next.lock', ref: 'head-sha')
                             .and_return(content2)
        end

        it 'identifies all the gem lock files' do
          expect(files.map(&:filename)).to eq(['my/Gemfile.lock', 'Gemfile_next.lock'])
        end

        it 'produces LockFileDiff instances with the expected attributes' do
          files
          expect(LockFileDiff).to have_received(:new)
                                    .with(filename: 'my/Gemfile.lock',
                                          base_file: 'content-1',
                                          head_file: 'content-2',
                                          patch: 'my-gem-patch',
                                          sha: 'head-sha')
          expect(LockFileDiff).to have_received(:new)
                                    .with(filename: 'Gemfile_next.lock',
                                          base_file: 'content-1',
                                          head_file: 'content-2',
                                          patch: 'next-gem-patch',
                                          sha: 'head-sha')
        end
      end
    end
  end
end
