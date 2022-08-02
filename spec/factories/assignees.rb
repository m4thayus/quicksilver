# frozen_string_literal: true

FactoryBot.define do
  factory :assignee do
    user
    task
  end
end
