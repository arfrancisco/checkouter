module CheckoutFlow
  class RemoveProductFromOrder
    OrderNotFoundError = Class.new(StandardError)
    OrderItemNotFoundError = Class.new(StandardError)

    def self.call(customer_name:, product_id:)
      new(customer_name:, product_id:).call
    end

    def initialize(customer_name:, product_id:)
      @customer_name = customer_name,
      @product_id = product_id
    end

    def call
      raise OrderNotFoundError, "Order for customer #{@customer_name} not found" unless order
      raise OrderItemNotFoundError, "Product with ID #{@product_id} not found in order for customer #{@customer_name}" unless order_item

      if order_item.quantity > 1
        order_item.decrement(:quantity)
        order_item.price = order_item.quantity * order_item.product.price
        order_item.save!
      else
        order_item.destroy!
      end
    end

    private

    def order
      @order ||= Order.find_by(name: @customer_name)
    end

    def order_item
      @order_item ||= order.order_items.find_by(product_id: @product_id)
    end
  end
end
