# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
#require "git_store"
require '../../lib/grit'
include Grit

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'fe8e4b4c13a786a31ec8c738f4aa7fc6'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

  @@repo = Repo.new("/home/danhigham/Projects/doc-repo")
  #@@store = GitStore.new("/home/danhigham/Projects/doc-repo")
end
