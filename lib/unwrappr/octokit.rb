# Wrapper around octokit
module Octokit
  def self.client
    @client ||= Client.new(access_token: ENV['GIT_TOKEN'])
  end
end
