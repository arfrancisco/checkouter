# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CheckoutFlow::Promos::BuyOneTakeOne do
  describe '.applicable?' do
    before do
      allow(CheckoutFlow::Promos::BuyOneTakeOne).to receive(:promo_code).and_return('BOGO')
    end

    context 'when product has the promo code assigned to it' do
      let(:product) { FactoryBot.create(:product, code: 'gr1', name: 'Green Tea', price: 50) }
      let(:order_item) { FactoryBot.create(:order_item, product:, quantity: 2, price: 100) }

      it 'returns true' do
        product.applicable_promos << 'BOGO'
        product.save!

        expect(described_class.applicable?(order_item:)).to be true
      end
    end

    context 'when product does not have the promo code assigned to it' do
      let(:product) { FactoryBot.create(:product, code: 'cf1', name: 'Coffee', price: 60, applicable_promos: []) }
      let(:order_item) { FactoryBot.create(:order_item, product:, quantity: 2, price: 120) }

      it 'returns false' do
        expect(described_class.applicable?(order_item:)).to be false
      end
    end

    context 'when product has different promo code assigned to it' do
      let(:product) { FactoryBot.create(:product, code: 'cf1', name: 'Coffee', price: 60) }
      let(:order_item) { FactoryBot.create(:order_item, product:, quantity: 2, price: 120) }

      it 'returns false' do
        product.applicable_promos << 'SOME_OTHER_PROMO'
        product.save!

        expect(described_class.applicable?(order_item:)).to be false
      end
    end
  end

  describe '.apply' do
    let(:product) { FactoryBot.create(:product, code: 'gr1', name: 'Green Tea', price: 50) }
    let(:order_item) { FactoryBot.create(:order_item, product:, quantity: 1, price: 150) }

    before do
      allow(CheckoutFlow::Promos::BuyOneTakeOne).to receive(:promo_code).and_return('BOGO')
      product.applicable_promos << 'BOGO'
      product.save!
    end

    context 'when order item quantity is just one' do
      it 'does not change the price' do
        order_item.update(quantity: 1, price: 50)
        described_class.apply!(order_item:)
        expect(order_item.price).to eq(50)
      end
    end

    context 'when order item quantity is two' do
      it 'reduces the price accordingly' do
        order_item.update(quantity: 2, price: 100)
        described_class.apply!(order_item:)
        expect(order_item.price).to eq(50)
      end
    end

    context 'when order item quantity is even' do
      it 'reduces the price accordingly' do
        order_item.update(quantity: 6, price: 300)
        described_class.apply!(order_item:)
        expect(order_item.price).to eq(150)
      end
    end

    context 'when order item quantity is odd' do
      it 'reduces the price accordingly' do
        order_item.update(quantity: 5, price: 250)
        described_class.apply!(order_item:)
        expect(order_item.price).to eq(150)
      end
    end
  end
end
