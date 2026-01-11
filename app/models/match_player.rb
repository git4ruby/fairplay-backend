class MatchPlayer < ApplicationRecord
  # Associations
  belongs_to :match
  belongs_to :user

  # Validations
  validates :team_number, presence: true, inclusion: { in: [ 1, 2 ], message: "must be 1 or 2" }
  validates :user_id, uniqueness: { scope: :match_id, message: "already in this match" }
end
