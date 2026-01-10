class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  # Roles enum: user (0), coach (1), admin (2)
  enum :role, { user: 0, coach: 1, admin: 2 }, default: :user

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :phone_number, format: { with: /\A[+]?[\d\s\-()]+\z/, message: "invalid format" }, allow_blank: true

  # Associations
  has_many :club_ownerships, dependent: :destroy
  has_many :owned_clubs, through: :club_ownerships, source: :club
  has_many :match_players, dependent: :destroy
  has_many :matches, through: :match_players
  has_many :reviews, dependent: :destroy

  # Helper method for full name
  def full_name
    "#{first_name} #{last_name}"
  end
end
