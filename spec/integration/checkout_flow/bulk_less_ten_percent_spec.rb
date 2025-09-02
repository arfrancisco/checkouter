# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'CheckoutFlow Get 10% discount on bulk order path' do
  let(:tea) { FactoryBot.create(:product, code: 'gr1', name: 'Green Tea', price: 50) }
  let(:coffee) { FactoryBot.create(:product, code: 'cf1', name: 'Coffee', price: 60) }

  it 'calculates total with 10% discount for bulk order' do
    # Assign promo to coffee
    coffee.update!(applicable_promos: [CheckoutFlow::Promos::BulkLessTenPercent.promo_code])

    # Customer adds items to their cart
    ::CheckoutFlow.customer_adds_product_to_order(customer_name: 'Bob', product_id: tea.id)
    ::CheckoutFlow.customer_adds_product_to_order(customer_name: 'Bob', product_id: coffee.id)
    ::CheckoutFlow.customer_adds_product_to_order(customer_name: 'Bob', product_id: coffee.id)
    ::CheckoutFlow.customer_adds_product_to_order(customer_name: 'Bob', product_id: coffee.id)

    order = Order.find_by(name: 'Bob')
    expect(order.order_items.count).to eq(2)
    expect(order.order_items.find_by(product_id: coffee.id).quantity).to eq(3)
    expect(order.order_items.find_by(product_id: coffee.id).price).to eq(162) # 180 - 10% = 162

    # System fetches total for display
    total = ::CheckoutFlow.system_calculates_order_total(customer_name: 'Bob')
    expect(total).to eq(212)

    # Customer removes one coffee from their cart
    # this should remove the 10% discount as quantity is now less than 3
    ::CheckoutFlow.customer_removes_product_from_order(customer_name: 'Bob', product_id: coffee.id)

    order.reload
    expect(order.order_items.count).to eq(2)
    expect(order.order_items.find_by(product_id: coffee.id).quantity).to eq(2)
    expect(order.order_items.find_by(product_id: coffee.id).price).to eq(120) # no discount

    # System fetches total for display
    total = ::CheckoutFlow.system_calculates_order_total(customer_name: 'Bob')
    expect(total).to eq(170) # 50 (tea) + 120 (coffee)
  end
end
