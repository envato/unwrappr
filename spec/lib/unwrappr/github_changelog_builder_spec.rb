module Unwrappr
  RSpec.describe GithubChangelogBuilder do
    subject(:build) { described_class.build(repository: repository, base: base, head: head) }
    let(:repository) { double('repository') }
    let(:base) { double('base') }
    let(:head) { double('head') }
    # let(:response) { [double('response')] }
    let(:commit) { double('commit', message: "hi!") }
    let(:commit_info) { double("commit information", commit: commit)}
    let(:response) { double('response', commits: [commit_info]) }

    context "with a successful request" do
      before do
        allow(Octokit.client).to receive(:compare).and_return(response)
      end

      it "returns an array of commit messages" do
        expect(subject).to eq(["hi!"])
      end
    end

    context "with NotFound error" do
      before do
        allow(Octokit.client).to receive(:compare).and_raise(Octokit::NotFound)
      end

      it "does not raise" do
        expect{subject}.not_to raise_error
      end

      it "returns an empty array" do
        expect(subject).to eq([])
      end
    end
  end
end
