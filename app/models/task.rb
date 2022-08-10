# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :owner, class_name: "User", optional: true

  validates :title, presence: true

  def self.humanize_duration(days)
    seconds = days * ActiveSupport::Duration::SECONDS_PER_DAY
    approx_seconds = if seconds.abs <= ActiveSupport::Duration::SECONDS_PER_WEEK
                       seconds
                     elsif seconds.abs <= ActiveSupport::Duration::SECONDS_PER_MONTH
                       (seconds / ActiveSupport::Duration::SECONDS_PER_WEEK * ActiveSupport::Duration::SECONDS_PER_WEEK).round
                     else
                       (seconds / ActiveSupport::Duration::SECONDS_PER_MONTH * ActiveSupport::Duration::SECONDS_PER_MONTH).round
                     end
    ActiveSupport::Duration.build(approx_seconds).inspect.titleize
  end

  def expected_duration
    (expected_at - started_at).to_i if expected_at.present? && started_at.present?
  end

  def actual_duration
    (completed_at - started_at).to_i if completed_at.present? && started_at.present?
  end

  def duration_delta
    (completed_at - expected_at).to_i if completed_at.present? && expected_at.present?
  end
end
