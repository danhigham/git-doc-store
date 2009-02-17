require 'uv'
include ApplicationHelper

class BrowserController < ApplicationController

 layout 'application', :except => :upload

  def index
    repo = Repository.find_by_name(params[:repo]) if !params[:repo].nil?

    if !repo.nil?
      git_repo = repo.git_repo
      @git_tree = git_repo.tree
      @path = params[:path] || []

      @selected_path = @path.join("\/")
      @top_commit = git_repo.commits.first

      #@current_path = @git_tree/"#{@selected_path}" || tree

      @blame_tree = !@top_commit.nil? ? git_repo.blame_tree(@top_commit.id, (@path.length > 0 ? @selected_path : '')).sort : nil
    else
      @repo_list = Repository.all
      render :action => 'repo_list'
    end
  end

  def show_blob
    repo = Repository.find_by_name(params[:repo])
    git_repo = Grit::Repo.new(repo.path) 
    blob = git_repo.blob(params[:id])
        
    @path = params[:tree].split('/')

    content_type = params[:type].to_sym
    set_response_type(content_type)
    
  @markup = Uv.parse( blob.data, "xhtml", content_type.to_s.downcase, true, "iplastic").gsub(/\n/, '<br />')
  end

  def upload

    @upload_path = params[:path].length > 0 ? params[:path].join("/") : "/"

    if params[:file]
      path = params[:path]  
      repo = Repository.find_by_name(params[:repo])
      git_repo = Grit::Repo.new(repo.path)      

      last_commit = git_repo.commits.length > 0 ? git_repo.commits.first : nil
      parent_commits = last_commit.nil? ? [] : [last_commit.id]
      last_tree = last_commit.nil? ? nil : last_commit.tree

      logger.debug("Parent Commit : #{parent_commits.inspect}")

      filename = params[:file].original_filename
      file = params[:file].read

      filename = "#{path}/#{filename}" unless path.empty?

      index = git_repo.index

      index.read_tree("master")
      index.add(filename, file)

      index.commit(params[:comment], parent_commits, nil, last_tree)

      repo.update_blame_table      

      redirect_to "/browse/#{repo.name}/#{path}"      
    end
  end

  def commits
    repo = Repository.find_by_name(params[:repo])
    git_repo = Grit::Repo.new(repo.path)
    @commit_list = git_repo.commits
  end

end
