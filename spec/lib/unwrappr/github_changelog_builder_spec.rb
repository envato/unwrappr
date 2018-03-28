module Unwrappr
	RSpec.describe GithubChangelogBuilder do
		subject(:build) { described_class.build(repository: repository, base: base, head: head) }
		let(:repository) { double('repository') }
		let(:base) { double('base') }
		let(:head) { double('head') }
		let(:response) { [double('response')] }

		context "with a successful request" do
			before do
				allow(Unwrappr::GithubChangelogBuilder).to receive(:build)
					.with(repository: repository, base: base, head: head)
					.and_return(response)
			end

			it "does not raise" do
				expect{subject}.not_to raise_error
			end
		end

		context "with a failed request" do
			class NotFoundError < StandardError; end

      before do
        allow(Unwrappr::GithubChangelogBuilder).to receive(:build)
          .with(repository: repository, base: base, head: head)
          .and_raise(NotFoundError)
      end

      it "raises" do
        expect{subject}.to raise_error(instance_of(NotFoundError))
      end
		end
	end
end
