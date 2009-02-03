# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def link_for_git_object(obj)
    if obj.class == Grit::Tree
      return "<a href='/store#{params[:path]}/#{obj.name}/'>#{obj.name}</a>"
    elsif obj.class == Grit::Blob
      type = ContentType.find(obj.name.scan(/\.([A-Za-z]+$)/).to_s)
      return "<a href='/blob/#{obj.id}?type=#{type.to_s}'>#{obj.name}</a>"
    end  
  end

  def set_response_type(content_type)

    if content_type == :JPEG
      response.headers["Content-Type"] = "image/jpeg"
    elsif content_type == :PNG
      response.headers["Content-Type"] = "image/png"
    elsif content_type == :GIF
      response.headers["Content-Type"] = "image/gif"
    elsif content_type == :TXT
      response.headers["Content-Type"] = "text/plain"

    end

  end    

  def modal_link(title, caption, url)
      "<a class=\"\" onclick=\"this.blur(); 
      Modalbox.show(this.href, {title: '#{title}', width: 600}); return false;\" 
      title=\"#{url}\" href=\"#{url}\">#{caption}</a>"
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
end



