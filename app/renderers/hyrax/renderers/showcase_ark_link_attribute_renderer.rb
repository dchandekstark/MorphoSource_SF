module Hyrax
  module Renderers
    class ShowcaseArkLinkAttributeRenderer < ShowcaseDefaultAttributeRenderer
      private

        def attribute_value_to_html(value)
          markup = ''
          return markup if value.blank? 
          # todo: move the urls (and possibly the logic) outside of renderer, e.g presenter?
          url = 'http://n2t.net/'
          link = link_to(value, "#{url}#{value}")
          markup << "<span class='glyphicon glyphicon-new-window'></span>&nbsp;<span class='showcase-link'>#{link}</span>"
          markup.html_safe
        end
    end
  end
end