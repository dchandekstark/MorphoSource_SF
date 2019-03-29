
module Hyrax
  module Renderers
    class ShowcaseDateAttributeRenderer < ShowcaseDefaultAttributeRenderer

      private

        def attribute_value_to_html(value)
          begin
            Date.parse(value).to_formatted_s(:long)
          rescue StandardError => e
            if e.message == 'invalid date'
              '(Invalid date)'
            else
              # if landed here. check e.message for the exception message
              '(Error)'
            end
          end
        end

    end
  end
end