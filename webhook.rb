require "sinatra"
require "json"

post "/issue/set/triage" do
  event_json = JSON.parse(params[:payload])
  event_json.inspect
end

