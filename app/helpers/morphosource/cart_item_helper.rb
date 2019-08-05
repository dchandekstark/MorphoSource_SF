module Morphosource::CartItemHelper

  # provide status label <span> element
  # arguments: label text, class, style
  def item_status_label(item)
    case item.request_status
    when 'Canceled'
      make_label("Canceled","label label-danger","background-color: gray;")
    when 'Denied'
      make_label("Denied","label label-danger",'')
    when 'Expired'
      make_label("Expired","label label-warning","background-color: orange;")
    when 'Approved'
      make_label("Approved","label label-success",'')
    when 'Cleared'
      make_label("Cleared","label label-info",'')
    when 'Requested'
      make_label("Requested","label label-primary",'')
    else
      make_label("Not Requested",'label label-info',"background-color: teal;")
    end
  end

  # provide action button
  # arguments: item, button text, button class, http method, style
  def item_action_button(item)
    case item.request_status
    when 'Approved'
      if !item.in_cart
        make_button(item,"Add to Cart",:move_to_cart_path,"btn btn-success",:put,'')
      else
        content_tag(:button, 'Item in Cart', class: "btn btn-success", disabled: true)
      end
    when 'Canceled'
      make_button(item,"Request Download",:request_item_path,"btn btn-info",:put,'')
    when 'Denied'
      if item.in_cart
        make_button(item,"Remove from Cart",:remove_items_path,"btn btn-danger",:delete,'')
      else
        content_tag(:span)
      end
    when 'Expired'
      make_button(item,"Request Again",:request_again_path,"btn btn-primary",:get,'')
    when 'Cleared'
     make_button(item,"Request Download",:request_item_path,"btn btn-info",:put,'')
    when 'Requested'
      make_button(item,"Cancel Request",:cancel_request_path,"btn btn-danger",:put,"background-color: gray;")
    when 'Downloadable'
      make_button(item,"Download Item",:download_items_path,"btn btn-info",:get,'')
    else
      make_button(item,"Request Download",:request_item_path,"btn btn-info",:put,'')
    end
  end

  def make_label(text,label,style)
    content_tag(:span, text, class: label, style: style)
  end

  def make_button(item,text,path,button_class,method,style)
    link_to text, main_app.send(path, item_id: item.id), class: button_class, style: style, method: method
  end

  def date(item,attribute)
    attribute = 'date_'.concat(attribute).to_sym
    item.send(attribute)&.strftime("%Y-%m-%d")
  end
end
