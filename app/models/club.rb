class Club < ApplicationRecord
  # Associations
  has_many :club_ownerships, dependent: :destroy
  has_many :owners, through: :club_ownerships, source: :user
  has_many :courts, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :address, presence: true
  validates :no_of_courts, presence: true, numericality: { greater_than: 0 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :phone_number, format: { with: /\A[+]?[\d\s\-()]+\z/, message: "invalid format" }, allow_blank: true
end
