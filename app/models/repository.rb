class Repository < ActiveRecord::Base

  def after_initialize
    ensure_index_hook
  end

  def git_repo
    Grit::Repo.new(self.path) 
  end

  def update_blame_table
    git = Grit::Git.new(self.path)
    git.sh("cd #{self.path} && git-log --pretty=oneline --name-only --parents --reverse --all > #{self.path}/.git/file-index")
  end

  private

  def ensure_index_hook
    git = Grit::Git.new(self.path)
    git.sh("cd #{self.path} && git-log --pretty=oneline --name-only --parents --reverse --all > #{self.path}/.git/file-index") if !File.exists?("#{self.path}/.git/file-index")

    add_blame_hook ("#{self.path}/.git/hooks/post-receive")
    add_blame_hook ("#{self.path}/.git/hooks/post-commit")

  end

  def add_blame_hook (file)
    if File.exists?(file)
      if File.read(file).grep(/### GitDocStore Hook ###/).empty? 
        File.open(file, "a") do |f|
          f.puts "\n### GitDocStore Hook ###\n"
          f.puts "git-log --pretty=oneline --name-only --parents --reverse --all > .git/file-index"
        end

        FileUtils.chmod 0755, file
      end
    end
  end

end
