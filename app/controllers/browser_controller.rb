include ApplicationHelper

class BrowserController < ApplicationController

 layout 'application', :except => :upload

  def index
    tree = @@repo.tree
    @path = params[:path] || []
    selected_path = @path.join("/")

    @current_path = tree/"#{selected_path}" || tree
  end

  def show_blob
    blob = @@repo.blob(params[:id])
    content_type = params[:type].to_sym

    set_response_type(content_type)
    render :text => blob.data
  end

  def upload
    if params[:file]  

      path = params[:path]
      filename = params[:file].original_filename
      file = params[:file].read

      filename = "#{path}/#{filename}" unless path.empty?

      index = @@repo.index

      index.read_tree("master")
      index.add(filename, file)
      index.commit('blah!')

      redirect_to "/browse/#{path}"      
    end
  end

end
