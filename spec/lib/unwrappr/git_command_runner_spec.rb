# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Unwrappr::GitCommandRunner do
  let(:fake_git) { instance_double(Git::Base, :fake_git) }

  before do
    described_class.reset_client
    allow(Git).to receive(:open).and_return(fake_git)
  end

  describe '#create_branch!' do
    subject(:create_branch!) { described_class.create_branch!(base_branch: base_branch) }
    let(:base_branch) { 'some_branch' }

    before { allow(Time).to receive(:now).and_return(Time.parse('2017-11-01 11:23')) }

    context 'Given current directory is not a git repo' do
      before do
        expect(fake_git).to receive(:current_branch).and_raise(Git::GitExecuteError)
      end

      specify do
        expect { create_branch! }.to raise_error(RuntimeError, 'Not a git working dir')
      end
    end

    context 'Given the current directory is a git repo' do
      before do
        expect(fake_git).to receive(:current_branch).and_return('main')
        allow(fake_git).to receive(:checkout)
      end

      context 'with a named base branch' do
        let(:base_branch) { 'origin/main' }

        it 'checks out a new branch based on the named branch, with a timestamp' do
          expect(fake_git).to receive(:branch).with('auto_bundle_update_20171101-1123').and_return(fake_git)

          expect(create_branch!).to be_nil

          expect(fake_git).to have_received(:checkout).with('origin/main').once
        end
      end

      context 'without a named base branch' do
        let(:base_branch) { nil }

        it 'checks out a new branch based on the current branch, with a timestamp' do
          expect(fake_git).to receive(:branch).with('auto_bundle_update_20171101-1123').and_return(fake_git)

          expect(create_branch!).to be_nil

          expect(fake_git).not_to have_received(:checkout).with(nil)
        end
      end

      context 'When there is some failure in creating the branch' do
        before do
          expect(fake_git).to receive(:branch)
            .with('auto_bundle_update_20171101-1123')
            .and_raise(Git::GitExecuteError)
        end

        specify do
          expect { create_branch! }.to raise_error(RuntimeError, "failed to create branch from 'some_branch'")
        end
      end
    end
  end

  describe '#commit_and_push_changes!' do
    subject(:commit_and_push_changes!) { described_class.commit_and_push_changes! }

    context 'Given the git add command fails' do
      before do
        expect(fake_git).to receive(:add).with(all: true).and_raise(Git::GitExecuteError)
      end

      specify do
        expect { commit_and_push_changes! }
          .to raise_error RuntimeError, 'failed to add git changes'
      end
    end

    context 'Given the git add command is successful' do
      before do
        expect(fake_git).to receive(:add).with(all: true).and_return(true)
      end

      context 'When the git commit command fails' do
        before do
          expect(fake_git).to receive(:commit).with('Automatic Bundle Update').and_raise(Git::GitExecuteError)
        end

        specify do
          expect { commit_and_push_changes! }.to raise_error(RuntimeError, 'failed to commit changes')
        end
      end

      context 'Given the git commit command is successful' do
        before do
          expect(fake_git).to receive(:commit).with('Automatic Bundle Update').and_return(true)
        end

        context 'Given the git push command fails' do
          before do
            expect(fake_git).to receive(:current_branch).and_return('branchname')
            expect(fake_git).to receive(:push).with('origin', 'branchname').and_raise(Git::GitExecuteError)
          end

          specify do
            expect { commit_and_push_changes! }
              .to raise_error(RuntimeError, 'failed to push changes')
          end
        end

        context 'Given the git push command is successful' do
          before do
            expect(fake_git).to receive(:current_branch).and_return('branchname')
            expect(fake_git).to receive(:push).with('origin', 'branchname').and_return(true)
          end

          it { is_expected.to be_nil }
        end
      end
    end
  end

  describe '#show' do
    subject(:show) { described_class.show('HEAD', 'Gemfile.lock') }

    context 'when the proxied git command succeeds' do
      before do
        expect(fake_git).to receive(:show).with('HEAD', 'Gemfile.lock').and_return('content')
      end

      it { is_expected.to eq('content') }
    end

    context 'when the proxied git command fails' do
      before do
        expect(fake_git).to receive(:show).and_raise(Git::GitExecuteError)
      end

      it { is_expected.to be_nil }
    end
  end

  describe '#file_exist?' do
    subject(:file_exist) { described_class.file_exist?('Gemfile.lock') }

    context 'when does not exist' do
      before do
        expect(fake_git).to receive(:ls_files).with('Gemfile.lock').and_return({})
      end

      it { is_expected.to be false }
    end

    context 'when it exists' do
      before do
        expect(fake_git).to receive(:ls_files)
          .with('Gemfile.lock')
          .and_return('Gemfile.lock' => {
                        path: 'Gemfile.lock',
                        mode_index: '100644',
                        sha_index: 'cabbage',
                        stage: '0'
                      })
      end

      it { is_expected.to be true }
    end
  end
end
