# frozen_string_literal: true

FactoryBot.define do
  factory :board do
    sequence(:name) { |n| "board-#{n}" }
    description { "Description" }
  end
end
