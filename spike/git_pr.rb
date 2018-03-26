require 'octokit'

client = Octokit::Client.new(access_token: 'token')

puts client.user.login

# Assumption this will be executed in the same directory as the cloned repository.
new_branch = `git checkout -b automated_bundle_update`

# Bundle Update happens here
bundle_update = `bundle update`

# git add and commit
commit_and_add = `git add -A && git commit -m "automated bundle update"`

push_branch = `git push origin automated_bundle_update`

# Submit a PR
client.create_pull_request(
  "gitorg/reponame",
  "master",
  "automated_bundle_update",
  "Test PR from ze Codesz",
  "description woot"
)
