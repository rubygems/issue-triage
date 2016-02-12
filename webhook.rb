require "sinatra"
require "octokit"
require "json"

module Webhook
  class App < Sinatra::Base
    configure do
      Octokit.configure do |o|
        o.access_token = ENV["ACCESS_TOKEN"]
      end

      set :repo,         ENV["REPO"]
      set :issue_labels, []

      ENV["ISSUE_LABEL"].split(",").each { |s| settings.issue_labels << s } unless ENV["ISSUE_LABEL"].nil?
    end

    post "/add/label" do
      data = JSON.parse(request.body.read)
      issue_number = Webhook.issue_number(data)

      Octokit.add_labels_to_an_issue(settings.repo, issue_number, settings.issue_labels)

      status 200
    end

    post "/remove/label" do
      data = JSON.parse(request.body.read)
      issue_number = Webhook.issue_number(data)

      Octokit.remove_all_labels(settings.repo, issue_number)

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
