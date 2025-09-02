# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'CheckoutFlow Happy Path' do
  let(:tea) { FactoryBot.create(:product, code: 'gr1', name: 'Green Tea', price: 50) }
  let(:coffee) { FactoryBot.create(:product, code: 'cf1', name: 'Coffee', price: 60) }

  it 'allows adding, calculating of total, and removal of order items' do
    # Customer adds items to their cart
    ::CheckoutFlow.customer_adds_product_to_order(customer_name: 'Alice', product_id: tea.id)
    ::CheckoutFlow.customer_adds_product_to_order(customer_name: 'Alice', product_id: coffee.id)

    order = Order.find_by(name: 'Alice')
    expect(order.order_items.count).to eq(2)
    expect(order.order_items.map(&:product).map(&:name)).to contain_exactly('Green Tea', 'Coffee')
    expect(order.order_items.find_by(product_id: tea.id).quantity).to eq(1)
    expect(order.order_items.find_by(product_id: coffee.id).quantity).to eq(1)

    # System fetches total for display
    total = ::CheckoutFlow.system_calculates_order_total(customer_name: 'Alice')
    expect(total).to eq(110)

    # Customer adds another coffee
    ::CheckoutFlow.customer_adds_product_to_order(customer_name: 'Alice', product_id: coffee.id)

    order.reload
    expect(order.order_items.count).to eq(2)
    expect(order.order_items.map(&:product).map(&:name)).to contain_exactly('Green Tea', 'Coffee')
    expect(order.order_items.find_by(product_id: tea.id).quantity).to eq(1)
    expect(order.order_items.find_by(product_id: coffee.id).quantity).to eq(2)

    # System fetches total for display
    total = ::CheckoutFlow.system_calculates_order_total(customer_name: 'Alice')
    expect(total).to eq(170)

    # Customer removes tea and one coffee
    ::CheckoutFlow.customer_removes_product_from_order(customer_name: 'Alice', product_id: tea.id)
    ::CheckoutFlow.customer_removes_product_from_order(customer_name: 'Alice', product_id: coffee.id)

    # System fetches total for display
    total = ::CheckoutFlow.system_calculates_order_total(customer_name: 'Alice')
    expect(total).to eq(60)
  end
end
