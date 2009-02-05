include ApplicationHelper

class BrowserController < ApplicationController

 layout 'application', :except => :upload

  def index
    repo = Repository.find_by_name(params[:repo]) if !params[:repo].nil?
    
    if !repo.nil?
    
      git_repo = Grit::Repo.new(repo.path)
      tree = git_repo.tree
      @path = params[:path] || []
      selected_path = @path.join("/")
      
      @commits = git_repo.commits
      @current_path = tree/"#{selected_path}" || tree
    else
      @repo_list = Repository.all
      render :action => 'repo_list'
    end
  end

  def show_blob
    repo = Repository.find_by_name(params[:repo])
    git_repo = Grit::Repo.new(repo.path) 
    blob = git_repo.blob(params[:id])
    
    content_type = params[:type].to_sym

    set_response_type(content_type)
    render :text => blob.data
  end

  def upload
    @upload_path = params[:path].length > 0 ? params[:path].join("/") : "/"

    if params[:file]
      path = params[:path]  
      repo = Repository.find_by_name(params[:repo])
      git_repo = Grit::Repo.new(repo.path)      

      filename = params[:file].original_filename
      file = params[:file].read

      filename = "#{path}/#{filename}" unless path.empty?

      index = git_repo.index

      index.read_tree("master")
      index.add(filename, file)

      index.commit(params[:comment])

      redirect_to "/browse/#{repo.name}/#{path}"      
    end
  end

end
