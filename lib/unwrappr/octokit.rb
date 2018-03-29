# frozen_string_literal: true

# Wrapper around octokit
module Octokit
  def self.client
    @client ||= Client.new(access_token: ENV['GITHUB_TOKEN'])
  end
end
