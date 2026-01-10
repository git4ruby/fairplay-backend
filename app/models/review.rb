class Review < ApplicationRecord
  # Associations
  belongs_to :match
  belongs_to :user

  # Active Storage
  has_one_attached :video

  # Enums
  enum :decision, { inn: 0, out: 1, uncertain: 2 }
  enum :status, { pending: 0, processing: 1, processed: 2, failed: 3 }, default: :pending

  # Validations
  validate :video_present
  validates :confidence, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

  private

  def video_present
    unless video.attached? || video_url.present?
      errors.add(:base, "Either video attachment or video URL must be present")
    end
  end
end
