#!/usr/bin/env ruby

require "yaml"
require_relative "asana.rb"

# Read local config
config = YAML.load(File.read("config.yaml"))

# Create a new Asana connection
asana = Asana.new(config["api_key"])

# Get a list of projects
projects = asana.projects_in_workspace(config["workspace_id"])

# Get tasks for each project
projects.each do |project|
  tasks = asana.tasks_for_project(project["id"])
  puts tasks.first.inspect
end



