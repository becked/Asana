#!/usr/bin/env ruby
#
# Display how much time we spend doing project tasks, as recorded on Asana.
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
hours_worked_regex = /^\[([\d\.]+)\]/

config["assignees"].each do |assignee|
  asana.recent_tasks_for_assignee_and_workspace(assignee, config["workspace_id"]).
  map { |e| asana.task(e["id"]) }.
  # We only care about tasks prefaced with [hours worked]
  select { |e| e["completed"] == true and e["name"] =~ hours_worked_regex }.each do |task|
    # Presumably the hours_worked_regex select will ensure this match is successful ...
    hours = task["name"].match(hours_worked_regex)[1].to_f
    # Not thrilled about having memberships to multiple projects (isn't that why we have tagging?)
    task["projects"].each { |e| projects[e["name"]] += hours }
    assignees[task["assignee"]["name"]] += hours
  end
end

# Sort and print a table
printf "\n%-7s %-3s %-10s\n", "HOURS", "|", "PROJECT"
printf "%s\n", "--------------------"
projects.sort { |a,b| a.last <=> b.last }.reverse.each do |project|
  printf "%-7.2f %-5s %-10s\n", project.last, "|", project.first
end
printf "\n%-7s %-3s %-10s\n", "HOURS", "|", "ASSIGNEE"
printf "%s\n", "--------------------"
assignees.sort { |a,b| a.last <=> b.last }.reverse.each do |assignee|
  printf "%-7.2f %-5s %-10s\n", assignee.last, "|", assignee.first
end
puts
