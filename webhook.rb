require "sinatra"
require "json"

post "/issue/set/triage" do
  event_json = JSON.parse(request.body.read)
  event_json
end

