class CartItem < ApplicationRecord
  belongs_to :media_cart
  paginates_per 10
end
