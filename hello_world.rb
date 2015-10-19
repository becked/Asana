#!/usr/bin/env ruby

require "rubygems"
require "JSON"
require "net/https"
require "yaml"

config = YAML.loads(File.read("config.yaml"))

api_key = config["api_key"]
workspace_id = WORKSPACE-ID
assignee = ASSIGNEE-EMAIL

# set up HTTPS connection
uri = URI.parse("https://app.asana.com/api/1.0/tasks")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_PEER

# set up the request
header = {
  "Content-Type" => "application/json"
}

req = Net::HTTP::Post.new(uri.path, header)
req.basic_auth(api_key, '')
req.body = {
  "data" => {
    "workspace" => workspace_id,
    "name" => "Hello World!",
    "assignee" => assignee
  }
}.to_json()

# issue the request
res = http.start { |http| http.request(req) }

# output
body = JSON.parse(res.body)
if body['errors'] then
  puts "Server returned an error: #{body['errors'][0]['message']}"
else
  puts "Created task with id: #{body['data']['id']}"
end
