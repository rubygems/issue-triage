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

      if data["action"] == "opened" || data["action"] == "synchronize"
        if data.has_key?("pull_request")
          files = Webhook.pull_request_files(issue_number)
          labels = []

          if files.any? { |file| Webhook.common_file?(file) }
            labels << "Rubygems" << "Bundler"
          else
            labels << "Bundler" if files.any? { |file| Webhook.bundler_file?(file) }
            labels << "Rubygems" if files.any? { |file| Webhook.rubygems_file?(file) }
          end

          labels << "CI" if files.any?(/\.github\/workflows\//)

          if data["action"] == "synchronize"
            current_labels = Webhook.issue_labels(issue_number)
            removed_labels = ["Rubygems", "Bundler", "CI"] - labels
            added_labels = labels

            Webhook.replace_all_labels(issue_number, current_labels - removed_labels + added_labels)
          else
            Webhook.add_labels_to_an_issue(issue_number, labels)
          end
        end
      end

      status 200
    end
  end

  def self.common_file?(file)
    file =~ /\.github\/workflows\// && file !~ /\.github\/workflows\/.*-(rubygems|bundler)\.yml/
  end

  def self.bundler_file?(file)
    file =~ /bundler\// || file == ".rubocop_bundler.yml" || file = /\.github\/workflows\/.*-bundler\.yml/
  end

  def self.rubygems_file?(file)
    !bundler_file?(file)
  end

  def self.pull_request_files(pr_number)
    Octokit.pull_request_files("rubygems/rubygems", pr_number).map {|data| data.filename}
  end

  def self.add_labels_to_an_issue(issue_number, labels)
    Octokit.add_labels_to_an_issue(ENV["REPO"], issue_number, labels)
  end

  def self.issue_labels(issue_number, labels)
    Octokit.issue_labels(ENV["REPO"], issue_number).map {|data| data.name}
  end

  def self.replace_all_labels(issue_number, labels)
    Octokit.replace_all_labels(ENV["REPO"], issue_number, labels)
  end

  def self.issue_number(json_data)
    if json_data.has_key? "pull_request"
      json_data["pull_request"]["number"]
    elsif json_data.has_key? "issue"
      json_data["issue"]["number"]
    end
  end
end
