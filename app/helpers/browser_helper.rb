module BrowserHelper
  def get_list_item_class (list, item)
    return "button last" if item == list.last
    return "button"
  end
end
