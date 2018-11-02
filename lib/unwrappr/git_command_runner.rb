# frozen_string_literal: true

require 'git'
require 'logger'
require 'octokit'

module Unwrappr
  # Runs Git commands
  module GitCommandRunner
    class << self
      def create_branch!
        raise 'Not a git working dir' unless git_dir?
        raise 'failed to create branch' unless branch_created?
      end

      def commit_and_push_changes!
        raise 'failed to add git changes' unless git_added_changes?
        raise 'failed to commit changes' unless git_committed?
        raise 'failed to push changes' unless git_pushed?
      end

      def make_pull_request!
        create_and_annotate_pull_request
      rescue Octokit::ClientError
        raise 'failed to create and annotate pull request'
      end

      def reset_client
        @git_client = nil
        @git = nil
        @github_token = nil
      end

      def show(revision, path)
        git.show(revision, path)
      rescue Git::GitExecuteError
        nil
      end

      private

      def git_dir?
        git_wrap { !current_branch_name.empty? }
      end

      def branch_created?
        timestamp = Time.now.strftime('%Y%d%m-%H%M').freeze
        git_wrap do
          git.checkout('origin/master')
          git.branch("auto_bundle_update_#{timestamp}").checkout
        end
      end

      def git_added_changes?
        git_wrap { git.add(all: true) }
      end

      def git_committed?
        git_wrap { git.commit('Automatic Bundle Update') }
      end

      def git_pushed?
        git_wrap { git.push('origin', current_branch_name) }
      end

      def current_branch_name
        git.current_branch
      end

      def repo_name_and_org
        repo_url = git.config('remote.origin.url').gsub(/\.git$/, '')
        pattern = %r{github.com[/:](?<org>.*)/(?<repo>.*)}
        m = pattern.match(repo_url)
        [m[:org], m[:repo]].join('/')
      end

      def create_and_annotate_pull_request
        pr = git_client.create_pull_request(
          repo_name_and_org,
          'master',
          current_branch_name,
          'Automated Bundle Update'
        )
        annotate_pull_request(pr.number)
      end

      def annotate_pull_request(pr_number)
        LockFileAnnotator.annotate_github_pull_request(
          repo: repo_name_and_org,
          pr_number: pr_number,
          client: git_client
        )
      end

      def git_client
        @git_client ||= Octokit::Client.new(access_token: github_token)
      end

      def github_token
        @github_token ||= ENV.fetch('GITHUB_TOKEN') do
          raise %(
Missing environment variable GITHUB_TOKEN.
See https://github.com/settings/tokens to set up personal access tokens.
Add to the environment:

    export GITHUB_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

)
        end
      end

      def git
        log_options = {}.tap do |opt|
          opt[:log] = Logger.new(STDOUT) if ENV['DEBUG']
        end

        @git ||= Git.open(Dir.pwd, log_options)
      end

      def git_wrap
        yield
        true
      rescue Git::GitExecuteError
        false
      end
    end
  end
end
