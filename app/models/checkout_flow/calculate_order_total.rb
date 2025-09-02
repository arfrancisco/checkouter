module CheckoutFlow
  class CalculateOrderTotal
    OrderNotFoundError = Class.new(StandardError)

    def self.call(customer_name:)
      new(customer_name:).call
    end

    def initialize(customer_name:)
      @customer_name = customer_name
    end

    def call
      raise OrderNotFoundError, "Order for customer #{@customer_name} not found" unless order

      order.order_items.sum(:price)
    end

    private

    def order
      @order ||= Order.find_by(name: @customer_name)
    end
  end
end
