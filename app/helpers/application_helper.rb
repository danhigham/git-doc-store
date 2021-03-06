# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def link_for_git_object(obj, parent_path)

    if obj.class == Grit::Tree
      path = params[:path].join("/")
      path = "/#{path}" if params[:path].length > 0
      return "<a href='/browse/#{params[:repo]}#{path}/#{obj.name}/'>#{obj.name}</a>"
    elsif obj.class == Grit::Blob
      type = ContentType.find(obj.name.scan(/\.([A-Za-z]+$)/).to_s)
      return "<a href='/blob/#{params[:repo]}/#{obj.id}?tree=#{CGI.escape(parent_path)}&type=#{type.to_s}'>#{obj.name}</a>"
    end  
  end

  def set_response_type(content_type)

    if content_type == :JPEG
      response.headers["Content-Type"] = "image/jpeg"
    elsif content_type == :PNG
      response.headers["Content-Type"] = "image/png"
    elsif content_type == :GIF
      response.headers["Content-Type"] = "image/gif"
    elsif [:TEXT, :RUBY, :HAML, :CSS].include?(content_type)
      response.headers["Content-Type"] = "text/html"
    end

  end    

  def modal_link(title, caption, url)
      "<a class=\"\" onclick=\"this.blur(); 
      Modalbox.show(this.href, {title: '#{title}', width: 600}); return false;\" 
      title=\"#{url}\" href=\"#{url}\">#{caption}</a>"
  end

  def get_blames_and_tree(repo, commit_hash, tree, path)
    blame_tree = Hash.new
    
    tree.contents.each { |x|
      if x.is_a? Blob
        req_path = path.length > 0 ? "#{path}/#{x.name}" : x.name 
        blame_tree[x] = Blob.blame(repo, commit_hash, req_path)
        
      else
        blame_tree[x] = nil
      end 
    }

    blame_tree.sort_by { |k,v| k.name.upcase }
    blame_tree
  end

end

class ContentType
  def ContentType.add_item(key,value)
      @hash ||= {}
      @hash[key]=value
  end

  def ContentType.const_missing(key)
      @hash[key]
  end   

  def ContentType.each
      @hash.each {|key,value| yield(key,value)}
  end

  def ContentType.find(ext)
      @hash.each { |key,value|
        return key if !value.grep(ext).empty?
      }

      return "TXT"
  end

  ContentType.add_item :JPEG, ['jpeg', 'jpg']
  ContentType.add_item :PNG, ['png']
  ContentType.add_item :GIF, ['gif']
  ContentType.add_item :RUBY, ['rb', 'rhtml']
  ContentType.add_item :HAML, ['haml']
  ContentType.add_item :CSS, ['sass', 'css']

end



