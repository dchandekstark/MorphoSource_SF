
module Hyrax
  module Renderers
    class ShowcaseDateAttributeRenderer < ShowcaseDefaultAttributeRenderer

      private

        def attribute_value_to_html(value)
          Date.parse(value).to_formatted_s(:long)
        end

    end
  end
end