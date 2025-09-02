module CheckoutFlow
  module Promos
    class BulkLessTenPercent
      PROMO_CODE = 'bulk10'.freeze
      MIN_QUANTITY = 3.freeze

      class << self
        def promo_code
          PROMO_CODE
        end

        def applicable?(order_item:)
          order_item.product.applicable_promos.include?(promo_code) && order_item.quantity >= MIN_QUANTITY
        end

        # If 3 or more items are bought, apply a 10% discount on the total price
        def apply!(order_item:)
          discounted_price = order_item.price * 0.9
          order_item.update(price: discounted_price)
        end
      end
    end
  end
end
