require "sinatra"
require "octokit"
require "json"

module Webhook
  class App < Sinatra::Base
    set :server, "thin"

    configure do
      Octokit.configure do |o|
        o.access_token = ENV["ACCESS_TOKEN"]
      end
    end

    post "/handle/label" do
      data = JSON.parse(request.body.read)
      issue_number = Webhook.issue_number(data)

      if data["action"] == "opened"
        Octokit.add_labels_to_an_issue(ENV["REPO"], issue_number, [ ENV["ISSUE_LABEL"] ])
      elsif data["action"] == "closed"
        Octokit.remove_label(ENV["REPO"], issue_number, ENV["ISSUE_LABEL"])
      end

      status 200
    end
  end

  def self.issue_number(json_data)
    if json_data.has_key? "pull_request"
      json_data["pull_request"]["number"]
    elsif json_data.has_key? "issue"
      json_data["issue"]["number"]
    end
  end
end
