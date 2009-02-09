include ApplicationHelper

class BrowserController < ApplicationController

 layout 'application', :except => :upload

  def index
    repo = Repository.find_by_name(params[:repo]) if !params[:repo].nil?
    
    if !repo.nil?
      git_repo = Grit::Repo.new(repo.path)
      tree = git_repo.tree
      @path = params[:path] || []

      @selected_path = @path.join("\/")
      @top_commit = git_repo.commits.first
 
      @current_path = tree/"#{@selected_path}" || tree
      @blame_tree = !@top_commit.nil? ? get_blames_and_tree(git_repo, @top_commit.id, @current_path, @selected_path) : nil

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

    #  Sample commit object    
    #  {
    #    "message"=>"hello", 
    #    "parents"=>[{"id"=>"b10c54e24ac0c42aeec334b9b45ec220de152294"}], 
    #    "author"=>{"name"=>"Dan Higham", "email"=>"dan.higham@gmail.com"}, 
    #    "id"=>"a627bf47cdc654ac74e8e95eb110710e73f05328", 
    #    "committed_date"=>"2009-02-06T06:34:05-05:00", 
    #    "authored_date"=>"2009-02-06T06:34:05-05:00", 
    #    "tree"=>"445e9aae50d3693b720da7025d042b10ea1ca5fe", 
    #    "committer"=>{"name"=>"Dan Higham", "email"=>"dan.higham@gmail.com"}
    #  }

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
      
      redirect_to "/browse/#{repo.name}/#{path}"      
    end
  end

  def commits
    repo = Repository.find_by_name(params[:repo])
    git_repo = Grit::Repo.new(repo.path)
    @commit_list = git_repo.commits
  end

end
