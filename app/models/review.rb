class Review < ApplicationRecord
  # Associations
  belongs_to :match
  belongs_to :user

  # Enums
  enum :decision, { inn: 0, out: 1, uncertain: 2 }
  enum :status, { pending: 0, processing: 1, processed: 2, failed: 3 }, default: :pending

  # Validations
  validates :video_url, presence: true
  validates :confidence, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
end
