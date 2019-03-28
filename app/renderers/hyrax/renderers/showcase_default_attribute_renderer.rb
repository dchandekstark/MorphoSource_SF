
module Hyrax
  module Renderers
    class ShowcaseDefaultAttributeRenderer < AttributeRenderer
      def render
        markup = ''
        return markup if values.blank? && !options[:include_empty]
        markup << %(<div class='row'>)
        markup << %(<div class='col-xs-5 showcase-label'>#{label}</div>)
        attributes = microdata_object_attributes(field).merge(class: "attribute attribute-#{field}")
        markup << %(<div class='col-xs-7 showcase-value'>)
        if values.blank?
          markup << %((Not entered))
        else
          Array(values).each do |value|
            markup << attribute_value_to_html(value.to_s)
          end
        end
        markup << %(</div>)
        markup << %(</div>)
        markup.html_safe
      end

    end
  end
end