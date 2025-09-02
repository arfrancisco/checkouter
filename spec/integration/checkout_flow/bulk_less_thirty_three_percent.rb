# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'CheckoutFlow Get 33% discount on bulk order path' do
  let(:tea) { FactoryBot.create(:product, code: 'gr1', name: 'Green Tea', price: 50) }
  let(:coffee) { FactoryBot.create(:product, code: 'cf1', name: 'Coffee', price: 60) }

  it 'applies a 33% discount when 3 or more items are purchased' do
    # with bulk 33% promo on coffee
    coffee.update!(applicable_promos: [CheckoutFlow::Promos::BulkLessThirtyThreePercent.promo_code])

    # Customer adds two coffees to their cart
    ::CheckoutFlow.customer_adds_product_to_order(customer_name: 'Bob', product_id: coffee.id)
    ::CheckoutFlow.customer_adds_product_to_order(customer_name: 'Bob', product_id: coffee.id)

    order = Order.find_by(name: 'Bob')
    expect(order.order_items.count).to eq(1)
    expect(order.order_items.find_by(product_id: coffee.id).quantity).to eq(2)
    expect(order.order_items.find_by(product_id: coffee.id).price).to eq(120) # 60 * 2

    # System fetches total for display
    total = ::CheckoutFlow.system_calculates_order_total(customer_name: 'Bob')
    expect(total).to eq(120)

    # Customer adds one more coffee to their cart, triggering the bulk discount
    ::CheckoutFlow.customer_adds_product_to_order(customer_name: 'Bob', product_id: coffee.id)

    order.reload
    expect(order.order_items.count).to eq(1)
    expect(order.order_items.find_by(product_id: coffee.id).quantity).to eq(3)
    expect(order.order_items.find_by(product_id: coffee.id).price).to eq(120) # now 120 because of 33% discount on 180

    # System fetches total for display
    total = ::CheckoutFlow.system_calculates_order_total(customer_name: 'Bob')
    expect(total).to eq(120)

    # Customer adds a tea to their cart, which does not have the bulk discount
    ::CheckoutFlow.customer_adds_product_to_order(customer_name: 'Bob', product_id: tea.id)

    order.reload
    expect(order.order_items.count).to eq(2)
    expect(order.order_items.find_by(product_id: tea.id).quantity).to eq(1)
    expect(order.order_items.find_by(product_id: tea.id).price).to eq(50)

    # System fetches total for display
    total = ::CheckoutFlow.system_calculates_order_total(customer_name: 'Bob')
    expect(total).to eq(170) # 120 (coffee with discount) + 50 (tea)

    # Customer removes one coffee from their cart, dropping below the minimum for the discount
    ::CheckoutFlow.customer_removes_product_from_order(customer_name: 'Bob', product_id: coffee.id)

    order.reload
    expect(order.order_items.count).to eq(2)
    expect(order.order_items.find_by(product_id: coffee.id).quantity).to eq(2)
    expect(order.order_items.find_by(product_id: coffee.id).price).to eq(120) # back to 120 because no discount
  end
end
