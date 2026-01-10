class Court < ApplicationRecord
  # Associations
  belongs_to :club
  has_many :matches, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :name, uniqueness: { scope: :club_id, message: "already exists in this club" }
end
