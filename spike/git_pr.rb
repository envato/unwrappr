require 'octokit'

client = Octokit::Client.new(access_token: ENV['GIT_TOKEN'])

puts client.user.login
time = Time.now.strftime('%Y%d%m-%H%m')
# Assumption this will be executed in the same directory as the cloned repository.
new_branch = `git checkout -b automated_bundle_update_#{time}`

# Bundle Update happens here
bundle_update = `bundle update`

# git add and commit
commit_and_add = `git add -A && git commit -m "automated bundle update"`

push_branch = `git push origin automated_bundle_update_#{time}`

# Submit a PR
client.create_pull_request(
  'gitorg/reponame',
  'master',
  'automated_bundle_update',
  'Test PR from ze Codesz',
  'description woot'
)
