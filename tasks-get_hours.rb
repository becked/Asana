#!/usr/bin/env ruby
#
# Display how much time we spend doing project tasks (according to Asana).
#
# We preface the task name with the hours it took to complete.
#   ex. [2] Write script to display hours worked on project tasks in Asana.

require "yaml"
require_relative "asana.rb"

# Read local config (assignees, api_key, workspace_id)
config = YAML.load(File.read("config.yaml"))

# Instantiate Asana
asana = Asana.new(config["api_key"])

# Grab recently completed tasks from people we care about
projects = Hash.new(0)
assignees = Hash.new(0)
config["assignees"].each do |assignee|
  asana.recent_tasks_for_assignee_and_workspace(assignee, config["workspace_id"]).
  map { |e| asana.task(e["id"]) }.
  # We only care about tasks prefaced with [hours worked]
  select { |e| e["completed"] == true and e["name"] =~ /^\[\d+\]/ }.each do |task|
    # Presumably the filter above will make sure this match is always successful ...
    hours = task["name"].match(/^\[(\d+)\]/)[1].to_i
    # Not thrilled about having memberships to multiple projects (isn't that why we have tagging?)
    task["projects"].each { |e| projects[e["name"]] += hours }
    assignees[task["assignee"]["name"]] += hours
  end
end

puts
puts "PROJECTS"
projects.each do |k,v|
  puts k + " => " + v.to_s
end
puts

puts "ASSIGNEES"
assignees.each do |k,v|
  puts k + " => " + v.to_s
end
puts
