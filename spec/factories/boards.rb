# frozen_string_literal: true

FactoryBot.define do
  factory :board do
    sequence(:name) { |n| "board-#{n}" }
    description { "Description" }

    factory :wishlist do
      name { Board::WISHLIST_SLUG }
    end

    factory :suggestions do
      name { Board::SUGGESTIONS_SLUG }
    end
  end
end
