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
      JSON.parse(http.request(request).body)["data"]
    end 
  end
  
  public
  def projects_in_workspace(workspace_id)
    uri = "https://app.asana.com/api/1.0/projects?workspace=#{workspace_id}"
    request(uri)
  end

  def tasks_for_project(project_id)
    uri = "https://app.asana.com/api/1.0/projects/#{project_id}/tasks"
    request(uri)
  end

end


