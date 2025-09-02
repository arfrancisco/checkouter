module CheckoutFlow
  module Promos
    class BuyOneTakeOne
      PROMO_CODE = 'b1t1'.freeze
      MIN_QUANTITY = 2.freeze

      class << self
        def promo_code
          PROMO_CODE
        end

        def applicable?(order_item:)
          order_item.product.applicable_promos.include?(promo_code) && order_item.quantity >= MIN_QUANTITY
        end

        # For every 1 item bought, 1 item is free
        # e.g. if quantity is 3, price is for 2 items
        def apply!(order_item:)
          free_items = order_item.quantity / 2
          payable_items = order_item.quantity - free_items
          order_item.update(price: payable_items * order_item.product.price)
        end
      end
    end
  end
end
