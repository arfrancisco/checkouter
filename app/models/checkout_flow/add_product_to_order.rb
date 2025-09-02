module CheckoutFlow
  class AddProductToOrder
    def self.call(customer_name:, product_id:)
      new(customer_name:, product_id:).call
    end

    def initialize(customer_name:, product_id:)
      @customer_name = customer_name
      @product_id = product_id
    end

    def call
      if order_item.present?
        order_item.increment(:quantity)
        order_item.price = order_item.quantity * product.price
        order_item.save!
      else
        order.order_items.create!(product:, quantity: 1, price: product.price)
      end
    end

    private

    def order
      @order ||= Order.find_or_create_by(name: @customer_name)
    end

    def product
      @product ||= Product.find(@product_id)
    end

    def order_item
      @order_item ||= order.order_items.find_by(product_id: product.id)
    end
  end
end
