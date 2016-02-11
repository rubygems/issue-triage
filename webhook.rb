require "sinatra"
require "octokit"
require "json"

configure do
  Octokit.configure do |o|
    o.access_token = ENV["ACCESS_TOKEN"]
  end

  set :repo,         ENV["REPO"]
  set :issue_labels, []
  set :pr_labels,    []

  ENV["ISSUE_LABEL"].split(",").each { |s| settings.issue_labels << s } unless ENV["ISSUE_LABEL"].nil?
  ENV["PR_LABEL"].split(",").each { |s| settings.pr_labels << s } unless ENV["PR_LABEL"].nil?
end

post "/issue/set/triage" do
  data = JSON.parse(request.body.read)
  issue_number = data["issue"]["number"]
  Octokit.add_labels_to_an_issue(settings.repo, issue_number, settings.issue_labels)

  status 200
end
