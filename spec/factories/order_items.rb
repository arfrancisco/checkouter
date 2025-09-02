FactoryBot.define do
  factory :order_item do
    association :order
    association :product

    quantity { 1 }
    price { 100 }
  end
end
