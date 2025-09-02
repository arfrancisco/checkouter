# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'CheckoutFlow Buy One Get One Path' do
  let(:tea) { FactoryBot.create(:product, code: 'gr1', name: 'Green Tea', price: 50) }
  let(:coffee) { FactoryBot.create(:product, code: 'cf1', name: 'Coffee', price: 60) }

  it 'applies promos correctly when adding or removing products from the order' do
    # with buy one get one free promo on tea
    tea.update!(applicable_promos: [CheckoutFlow::Promos::BuyOneTakeOne.promo_code])

    # Customer adds one tea to their cart
    ::CheckoutFlow.customer_adds_product_to_order(customer_name: 'Alice', product_id: tea.id)

    order = Order.find_by(name: 'Alice')
    expect(order.order_items.count).to eq(1)
    expect(order.order_items.find_by(product_id: tea.id).price).to eq(50)

    # Customer adds another tea to their cart
    # this should trigger the promo and make the second tea free
    ::CheckoutFlow.customer_adds_product_to_order(customer_name: 'Alice', product_id: tea.id)
    order.reload
    expect(order.order_items.count).to eq(1)
    expect(order.order_items.find_by(product_id: tea.id).quantity).to eq(2)
    expect(order.order_items.find_by(product_id: tea.id).price).to eq(50) # still 50 because second is free

    # Customer adds coffee to their cart
    # no promo on coffee, so price should be normal
    ::CheckoutFlow.customer_adds_product_to_order(customer_name: 'Alice', product_id: coffee.id)

    order.reload
    expect(order.order_items.count).to eq(2)
    expect(order.order_items.find_by(product_id: coffee.id).quantity).to eq(1)
    expect(order.order_items.find_by(product_id: coffee.id).price).to eq(60)

    # System fetches total for display
    # total should be 50 (tea) + 60 (coffee) = 110
    total = ::CheckoutFlow.system_calculates_order_total(customer_name: 'Alice')
    expect(total).to eq(110)

    # Customer adds one more tea to their cart
    # this should make the third tea chargeable again (no longer free)
    ::CheckoutFlow.customer_adds_product_to_order(customer_name: 'Alice', product_id: tea.id)

    order.reload
    expect(order.order_items.count).to eq(2)
    expect(order.order_items.find_by(product_id: tea.id).quantity).to eq(3)
    expect(order.order_items.find_by(product_id: tea.id).price).to eq(100) # now 100 because two are chargeable

    # System fetches total for display
    # total should be 100 (tea) + 60 (coffee) = 160
    total = ::CheckoutFlow.system_calculates_order_total(customer_name: 'Alice')
    expect(total).to eq(160)

    # Customer removes one tea from their cart
    # this should make the second tea free again
    ::CheckoutFlow.customer_removes_product_from_order(customer_name: 'Alice', product_id: tea.id)

    order.reload
    expect(order.order_items.count).to eq(2)
    expect(order.order_items.find_by(product_id: tea.id).quantity).to eq(2)
    expect(order.order_items.find_by(product_id: tea.id).price).to eq(50) # back to 50 because one is free again

    # System fetches total for display
    # total should be 50 (tea) + 60 (coffee) = 110
    total = ::CheckoutFlow.system_calculates_order_total(customer_name: 'Alice')
    expect(total).to eq(110)

    # Customer removes one more tea from their cart
    # now only one tea left, so no free teas
    ::CheckoutFlow.customer_removes_product_from_order(customer_name: 'Alice', product_id: tea.id)

    order.reload
    expect(order.order_items.count).to eq(2)
    expect(order.order_items.find_by(product_id: tea.id).quantity).to eq(1)
    expect(order.order_items.find_by(product_id: tea.id).price).to eq(50) # still 50 because only one tea

    # System fetches total for display
    # total should be 50 (tea) + 60 (coffee) = 110
    total = ::CheckoutFlow.system_calculates_order_total(customer_name: 'Alice')
    expect(total).to eq(110)

    # Customer removes the last tea from their cart
    ::CheckoutFlow.customer_removes_product_from_order(customer_name: 'Alice', product_id: tea.id)

    order.reload
    expect(order.order_items.count).to eq(1)
    expect(order.order_items.find_by(product_id: coffee.id).quantity).to eq(1)
    expect(order.order_items.find_by(product_id: coffee.id).price).to eq(60) # coffee remains unchanged

    # System fetches total for display
    # total should be 60 (coffee) only
    total = ::CheckoutFlow.system_calculates_order_total(customer_name: 'Alice')
    expect(total).to eq(60)
  end
end
