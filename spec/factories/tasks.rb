# frozen_string_literal: true

FactoryBot.define do
  factory :task do
    title { "Title" }
    status { "Status Here" }
    description { "Description" }
    started_at { 1.month.ago }
    expected_at { 2.weeks.ago }
    completed_at { 2.hours.ago }
    point_estimate { 5 }
    points { 8 }
  end
end
