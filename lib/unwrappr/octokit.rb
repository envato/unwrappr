# frozen_string_literal: true

# Wrapper around octokit
module Octokit
  def self.client
    @client ||= Client.new(access_token: access_token_from_environment)
  end

  def self.access_token_from_environment
    ENV.fetch('GITHUB_TOKEN') do
      raise <<~MESSAGE
        Missing environment variable GITHUB_TOKEN.
        See https://github.com/settings/tokens to set up personal access tokens.
        Add to the environment:

            export GITHUB_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

      MESSAGE
    end
  end
end
