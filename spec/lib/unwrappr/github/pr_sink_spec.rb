# frozen_string_literal: true

module Unwrappr
  RSpec.describe Github::PrSink do
    subject(:pr_sink) { Github::PrSink.new(repo, pr_number, client) }

    let(:repo) { 'envato/unwrappr' }
    let(:pr_number) { 223 }
    let(:client) { instance_spy(Octokit::Client) }

    describe '#annotate_change' do
      subject(:annotate_change) { pr_sink.annotate_change(gem_change, message) }

      let(:message) { 'the-message' }
      let(:gem_change) do
        double(
          GemChange,
          sha: 'ba046f5',
          filename: 'the/Gemfile.lock',
          line_number: 98
        )
      end

      it 'sends the annotation to GitHub' do
        annotate_change
        expect(client).to have_received(:create_pull_request_comment)
          .with(
            repo,
            pr_number,
            message,
            'ba046f5',
            'the/Gemfile.lock',
            98
          )
      end
    end
  end
end
