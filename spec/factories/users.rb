# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "user_#{n}" }
    sequence(:email) { |n| "user_#{n}@example.test" }
    password { "password" }

    factory :admin_user do
      email { User::ADMINISTRATORS.first }
    end

    factory :engineer_user do
      email { User::ENGINEERS.first }
    end

    factory :member_user do
      email { User::MEMBERS.first }
    end

    factory :guest_user do
      email { User::GUESTS.first }
    end
  end
end
