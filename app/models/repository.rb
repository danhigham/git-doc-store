class Repository < ActiveRecord::Base

  def git_repo
    Grit::Repo.new(self.path) 
  end

end
