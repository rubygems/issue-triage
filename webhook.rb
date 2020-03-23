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
        if data.has_key?("pull_request")
          files = Webhook.pull_request_files(issue_number)
          if files.any?(/bundler\//)
            Octokit.add_labels_to_an_issue(ENV["REPO"], issue_number, [ "Bundler" ])
          end
        end
      elsif data["action"] == "closed"
        Octokit.remove_label(ENV["REPO"], issue_number, ENV["ISSUE_LABEL"])
      end

      status 200
    end
  end

  def self.pull_request_files(pr_number)
    Octokit.pull_request_files("rubygems/rubygems", pr_number).map {|data| data.filename}
  end

  def self.issue_number(json_data)
    if json_data.has_key? "pull_request"
      json_data["pull_request"]["number"]
    elsif json_data.has_key? "issue"
      json_data["issue"]["number"]
    end
  end
end
