# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CheckoutFlow::Promos::BulkLessTenPercent do
  describe '.applicable?' do
    let(:product) { FactoryBot.create(:product, code: 'cf1', name: 'Coffee', price: 60) }
    let!(:order_item) { FactoryBot.create(:order_item, product:, quantity: 3, price: 180) }

    before do
      product.update!(applicable_promos: [described_class.promo_code])
    end

    context 'when product has the promo code assigned to it' do
      it 'returns true' do
        expect(described_class.applicable?(order_item:)).to be true
      end
    end

    context 'when order item quantity is less than 3' do
      it 'returns false' do
        order_item.update(quantity: 2, price: 120)
        expect(described_class.applicable?(order_item:)).to be false
      end
    end

    context 'when product does not have the promo code assigned to it' do
      it 'returns false' do
        product.applicable_promos = []
        product.save!

        expect(described_class.applicable?(order_item:)).to be false
      end
    end

    context 'when product has different promo code assigned to it' do
      it 'returns false' do
        product.update!(applicable_promos: ['SOME_OTHER_PROMO'])

        expect(described_class.applicable?(order_item:)).to be false
      end
    end
  end

  describe '.apply!' do
    let(:product) { FactoryBot.create(:product, code: 'cf1', name: 'Coffee', price: 60) }
    let!(:order_item) { FactoryBot.create(:order_item, product:, quantity: 3, price: 180) }

    before do
      product.update!(applicable_promos: [described_class.promo_code])
    end

    it 'applies a 10% discount to the order item price' do
      described_class.apply!(order_item:)
      order_item.reload

      expect(order_item.price).to eq(162) # 180 - 10% = 162
    end
  end
end
