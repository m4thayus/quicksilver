# frozen_string_literal: true

class Assignee < ApplicationRecord
  belongs_to :user
  belongs_to :task
end
