module CheckoutFlow
  class << self
    def customer_adds_product_to_order(customer_name:, product_id:)
      AddProductToOrder.call(customer_name:, product_id:)
    end

    def system_calculates_order_total(customer_name:)
      CalculateOrderTotal.call(customer_name:)
    end

    def customer_removes_product_from_order(customer_name:, product_id:)
      RemoveProductFromOrder.call(customer_name:, product_id:)
    end
  end
end
