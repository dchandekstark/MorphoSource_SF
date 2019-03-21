
module Hyrax
  class InCollectionBadge
    include ActionView::Helpers::TagHelper

    # @param is_voucher [String] the current is_voucher
    def initialize(is_voucher)
      @is_voucher = is_voucher
    end

    # Draws a span tag with styles for a bootstrap label
    def render
      content_tag(:span, text, class: "label label-primary")
    end

    private

      def text
        if @is_voucher == 'Yes'
          'In Collection'
        else
          'Not in Collection'
        end
      end

  end
end