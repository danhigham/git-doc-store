include ApplicationHelper

class StoreController < ApplicationController

  def index
    tree = @@repo.commits.first.tree
    selected_path = params[:path]
    
    @current_path = tree/"#{selected_path}" || tree
  end

  def blob

  end

  def show_blob
    blob = @@repo.blob(params[:id])
    content_type = params[:type].to_sym

    set_response_type(content_type)
    render :text => blob.data
  end

end
