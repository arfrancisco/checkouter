# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CheckoutFlow::CalculateOrderTotal do
  describe '.call' do
    context 'when customer order does not exist' do
      it 'raises an error' do
        expect {
          described_class.call(customer_name: 'Alice')
        }.to raise_error(CheckoutFlow::CalculateOrderTotal::OrderNotFoundError, 'Order for customer Alice not found')
      end
    end

    context 'when customer order exists' do
      let(:tea) { FactoryBot.create(:product, code: 'gr1', name: 'Green Tea', price: 50) }
      let(:coffee) { FactoryBot.create(:product, code: 'cf1', name: 'Coffee', price: 100) }
      let!(:existing_order) do
        order = FactoryBot.create(:order, name: 'Alice')
        order.order_items.create!(product: tea, quantity: 2, price: 100)
        order.order_items.create!(product: coffee, quantity: 1, price: 100)
        order
      end

      it 'calculates the total of the order for the given customer' do
        total = described_class.call(customer_name: 'Alice')
        expect(total).to eq(200)
      end
    end
  end
end
