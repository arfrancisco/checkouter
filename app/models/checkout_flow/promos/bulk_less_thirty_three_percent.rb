module CheckoutFlow
  module Promos
    class BulkLessThirtyThreePercent
      PROMO_CODE = 'bulk33'.freeze
      MIN_QUANTITY = 3.freeze

      class << self
        def promo_code
          PROMO_CODE
        end

        def applicable?(order_item:)
          order_item.product.applicable_promos.include?(promo_code) && order_item.quantity >= MIN_QUANTITY
        end

        # If 3 or more items are bought, apply a 33% discount on the total price
        def apply!(order_item:)
          discounted_price = order_item.price * 0.67 # Cleaner way to apply a 33% discount instead of multiplying by 0.66
          order_item.update(price: discounted_price)
        end
      end
    end
  end
end
