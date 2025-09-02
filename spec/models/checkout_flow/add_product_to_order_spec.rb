# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CheckoutFlow::AddProductToOrder do
  describe '.call' do
    let(:tea) { FactoryBot.create(:product, code: 'gr1', name: 'Green Tea', price: 50) }

    context 'when customer order does not exist' do
      it 'creates a new order and adds the product' do
        described_class.call(customer_name: 'Alice', product_id: tea.id)

        order = Order.find_by(name: 'Alice')
        expect(order).not_to be_nil
        expect(order.order_items.count).to eq(1)
        expect(order.order_items.first.product.name).to eq('Green Tea')
        expect(order.order_items.first.quantity).to eq(1)
        expect(order.order_items.first.price).to eq(50)
      end
    end

    context 'when customer order exists' do
      let!(:existing_order) do
        order = FactoryBot.create(:order, name: 'Alice')
        FactoryBot.create(:order_item, order:, product: tea, quantity: 1, price: 50)
        order
      end
      let(:jam) { FactoryBot.create(:product, code: 'jm1', name: 'Jam', price: 100) }

      it 'adds the product to the existing order' do
        described_class.call(customer_name: 'Alice', product_id: jam.id)

        order = Order.find_by(name: 'Alice')
        expect(order.order_items.count).to eq(2)
        expect(order.order_items.map(&:product).map(&:name)).to contain_exactly('Green Tea', 'Jam')
        expect(order.order_items.find_by(product: jam).quantity).to eq(1)
        expect(order.order_items.find_by(product: jam).price).to eq(100)
      end
    end

    context 'when adding the same product multiple times' do
      it 'increments the quantity of the product in the order' do
        described_class.call(customer_name: 'Alice', product_id: tea.id)

        order = Order.find_by(name: 'Alice')
        expect(order.order_items.count).to eq(1)
        expect(order.order_items.first.product.name).to eq('Green Tea')
        expect(order.order_items.first.quantity).to eq(1)
        expect(order.order_items.first.price).to eq(50)

        described_class.call(customer_name: 'Alice', product_id: tea.id)
        order.reload

        expect(order.order_items.count).to eq(1)
        expect(order.order_items.first.product.name).to eq('Green Tea')
        expect(order.order_items.first.quantity).to eq(2)
        expect(order.order_items.first.price).to eq(100)
      end
    end

    context 'when product is applicable for a promo' do
      it 'applies the promo when adding the product' do
        tea.update!(applicable_promos: [CheckoutFlow::Promos::BuyOneTakeOne.promo_code])

        described_class.call(customer_name: 'Alice', product_id: tea.id)

        expect(CheckoutFlow::Promos::BuyOneTakeOne).to receive(:applicable?).and_call_original
        expect(CheckoutFlow::Promos::BuyOneTakeOne).to receive(:apply!).and_call_original

        described_class.call(customer_name: 'Alice', product_id: tea.id)
      end
    end
  end
end
