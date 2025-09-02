# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CheckoutFlow::RemoveProductFromOrder do
  describe '.call' do
    let(:tea) { FactoryBot.create(:product, code: 'gr1', name: 'Green Tea', price: 50) }

    context 'when customer order does not exist' do
      it 'raises an error' do
        expect  {
          described_class.call(customer_name: 'Alice', product_id: tea.id)
        }.to raise_error(CheckoutFlow::RemoveProductFromOrder::OrderNotFoundError, 'Order for customer Alice not found')
      end
    end

    context 'when customer order exists' do
      let!(:existing_order) { FactoryBot.create(:order, name: 'Alice') }

      context 'when the product is in the order' do
        it 'removes the product from the order' do
          existing_order.order_items.create!(product: tea, quantity: 1, price: 50)

          described_class.call(customer_name: 'Alice', product_id: tea.id)
          existing_order.reload

          expect(existing_order.order_items.count).to eq(0)
        end
      end

      context 'when removing a product that was added multiple times' do
        it 'decrements the quantity of the product in the order' do
          existing_order.order_items.create!(product: tea, quantity: 2, price: 100)

          described_class.call(customer_name: 'Alice', product_id: tea.id)
          existing_order.reload

          expect(existing_order.order_items.count).to eq(1)
          expect(existing_order.order_items.first.product.name).to eq('Green Tea')
          expect(existing_order.order_items.first.quantity).to eq(1)
          expect(existing_order.order_items.first.price).to eq(50)
        end
      end

      context 'when the product is not in the order' do
        it 'raises an error' do
          expect {
            described_class.call(customer_name: 'Alice', product_id: tea.id)
          }.to raise_error(CheckoutFlow::RemoveProductFromOrder::OrderItemNotFoundError, "Product with ID #{tea.id} not found in order for customer Alice")
        end
      end
    end
  end
end
