class Admin::RepositoryController < ApplicationController
  layout 'application', :except => [:register, :delete]

  def index
    @repos = Repository.find(:all)
  end

  def add
    @repo = Repository.new(params[:repository])
    @repo.save

    git_path = "#{@repo.path}/.git"

    #Check to see if repository physically exists
    if !File.directory? git_path
      FileUtils.mkdir_p git_path
      @repo = Grit::Repo.init_bare git_path
    end

    redirect_to '/admin/repository'
  end

  def delete
    @repo = Repository.find_by_name(params[:id])
  end

  def remove
    Repository.find(params[:id]).destroy
    redirect_to '/admin/repository'
  end
end
