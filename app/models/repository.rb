class Repository < ActiveRecord::Base

  def after_initialize
    ensure_index_hook
  end

  def git_repo
    Grit::Repo.new(self.path) 
  end

  private

  def ensure_index_hook
    git = Grit::Git.new(self.path)
    git.sh('git-log --pretty=oneline --name-only --parents --reverse --all > .git/file-index') if !File.exists?('.git/file-index')

    if File.read('.git/hooks/post-receive').grep(/### GitDocStore Hook ###/).empty? 
      File.open(".git/hooks/post-receive", "a") do |f|
        f.puts "\n### GitDocStore Hook ###\n"
        f.puts "git log --pretty=oneline --name-only --parents --reverse [old-rev]..[new-rev] >> file-index"
      end
    end

    if File.read('.git/hooks/post-commit').grep(/### GitDocStore Hook ###/).empty? 
      File.open(".git/hooks/post-commit", "a") do |f|
        f.puts "\n### GitDocStore Hook ###\n"
        f.puts "git log --pretty=oneline --name-only --parents --reverse [old-rev]..[new-rev] >> file-index"
      end
    end

  end

end
