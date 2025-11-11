# frozen_string_literal: true

module Unwrappr
  RSpec.describe Github::PrSink do
    subject(:pr_sink) { Github::PrSink.new(repo, pr_number, client, delay: delay) }

    let(:repo) { 'envato/unwrappr' }
    let(:pr_number) { 223 }
    let(:client) { instance_spy(Octokit::Client) }
    let(:delay) { 0 } # Use 0 delay in tests for speed

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

      context 'when posting multiple comments' do
        let(:delay) { 0.1 }
        let(:gem_change2) do
          double(
            GemChange,
            sha: 'abc123',
            filename: 'the/Gemfile.lock',
            line_number: 99
          )
        end

        it 'throttles requests with a delay' do
          start_time = Time.now
          pr_sink.annotate_change(gem_change, message)
          pr_sink.annotate_change(gem_change2, 'another message')
          elapsed = Time.now - start_time

          expect(elapsed).to be >= delay
          expect(client).to have_received(:create_pull_request_comment).twice
        end
      end

      context 'when GitHub returns "submitted too quickly" error' do
        let(:error) do
          Octokit::UnprocessableEntity.new(
            status: 422,
            body: 'Validation Failed: was submitted too quickly'
          )
        end

        before do
          call_count = 0
          allow(client).to receive(:create_pull_request_comment) do
            call_count += 1
            raise error if call_count == 1
            true
          end
        end

        it 'retries the request after a delay' do
          expect { annotate_change }.not_to raise_error
          expect(client).to have_received(:create_pull_request_comment).twice
        end
      end

      context 'when retry limit is exceeded' do
        let(:error) do
          Octokit::UnprocessableEntity.new(
            status: 422,
            body: 'Validation Failed: was submitted too quickly'
          )
        end

        before do
          allow(client).to receive(:create_pull_request_comment).and_raise(error)
        end

        it 'raises the error after max retries' do
          expect { annotate_change }.to raise_error(Octokit::UnprocessableEntity)
          expect(client).to have_received(:create_pull_request_comment).exactly(3).times
        end
      end
    end
  end
end
