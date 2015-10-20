require "net/https"
require "json"
require "yaml"

class Asana
  def initialize(api_key)
    @api_key = api_key
  end

  private
  def request(uri, params={})
    uri = URI.parse(uri)
    Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
      if params[:post]
        request = Net::HTTP::Post.new(uri)
        request.set_form_data params
      else
        request = Net::HTTP::Get.new(uri)
      end
      request.basic_auth(@api_key, "")
      response = http.request(request)
      errors = JSON.parse(http.request(request).body)["errors"]
      puts errors.inspect if errors
      JSON.parse(http.request(request).body)["data"]
    end 
  end
  
  public
  def projects_in_workspace(workspace_id)
    uri = "https://app.asana.com/api/1.0/projects?workspace=#{workspace_id}"
    request(uri)
  end

  def user(user_id)
    uri = "https://app.asana.com/api/1.0/users/#{user_id}"
    request(uri)
  end

  def task(task_id)
    uri = "https://app.asana.com/api/1.0/tasks/#{task_id}"
    request(uri)
  end

  def users_in_workspace(workspace_id)
    uri = "https://app.asana.com/api/1.0/workspaces/#{workspace_id}/users"
    request(uri)
  end

  def tasks_for_assignee_and_workspace(assignee, workspace_id)
    uri = "https://app.asana.com/api/1.0/tasks/?assignee=#{assignee}&workspace=#{workspace_id}"
    request(uri)
  end

  # TODO fix the timezone here
  # Do we really want to hard set one month to be equal to "recent"?
  def recent_tasks_for_assignee_and_workspace(assignee, workspace_id)
    uri = "https://app.asana.com/api/1.0/tasks/?assignee=#{assignee}&workspace=#{workspace_id}&modified_since='#{Time.now.strftime("%Y-%m-01T%H:%M:%S.158Z")}'"
    request(uri)
  end

  def tasks_for_project(project_id)
    # Why are there two ways to do this? Which is better? Does it matter?
    #uri = "https://app.asana.com/api/1.0/projects/#{project_id}/tasks"
    uri = "https://app.asana.com/api/1.0/tasks/?project=#{project_id}"
    request(uri)
  end

end


