# frozen_string_literal: true

FactoryBot.define do
  factory :task do
    title { "Title" }
    description { "Description" }
    started_at { 1.month.ago }
    expected_at { 2.weeks.ago }
    completed_at { 2.hours.ago }
  end
end
