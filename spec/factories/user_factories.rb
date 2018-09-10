FactoryBot.define do
  factory :user do
    sequence(:id) { |n| "user#{n}@example.com" }
    sequence(:email) { |n| "first.last#{n}@example.com" }
    password {'secret'}
  end
end
