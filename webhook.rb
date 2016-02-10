require "sinatra"
require "octokit"
require "json"

configure do
  Octokit.configure do |o|
    o.access_token = "02b8d1ede86c8abb1724581822a7663e4c035e38"
  end
end

post "/issue/set/triage" do
  data = JSON.parse(request.body.read)
  issue_number = data["issue"]["number"]
  Octokit.add_labels_to_an_issue("bronzdoc/test", issue_number, ["triage"])

  status 200
end
