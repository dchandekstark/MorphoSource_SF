module Hyrax
  module Renderers
    class ShowcaseIdigbioLinkAttributeRenderer < ShowcaseDefaultAttributeRenderer
      private

        def attribute_value_to_html(value)
          markup = ''
          return markup if value.blank? 
#byebug
          # check field label to determine the idigbio url
          # todo: move the urls outside of renderer, possibly presenter
          link = link_to(value, "https://www.idigbio.org/portal/records/#{value}")
          markup << "<span class='glyphicon glyphicon-new-window'></span>&nbsp;#{link}"
          markup.html_safe
        end
    end
  end
end