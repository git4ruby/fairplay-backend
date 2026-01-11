class Match < ApplicationRecord
  # Associations
  belongs_to :court
  has_many :match_players, dependent: :destroy
  has_many :players, through: :match_players, source: :user
  has_many :reviews, dependent: :destroy

  # Active Storage - Multiple video attachments for different rallies
  has_many_attached :videos

  # Enums
  enum :match_type, { singles: 0, doubles: 1 }, default: :singles
  enum :status, { scheduled: 0, ongoing: 1, finished: 2 }, default: :scheduled

  # Validations
  validate :correct_number_of_players

  # Helper methods
  def team1_players
    players.joins(:match_players).where(match_players: { team_number: 1 })
  end

  def team2_players
    players.joins(:match_players).where(match_players: { team_number: 2 })
  end

  private

  def correct_number_of_players
    return if match_players.empty? # Skip during creation

    player_count = match_players.size
    expected_count = singles? ? 2 : 4

    if player_count != expected_count
      errors.add(:base, "#{match_type} match must have exactly #{expected_count} players")
    end
  end
end
