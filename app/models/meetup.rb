class Meetup < ActiveRecord::Base
  has_many :meetupowners
  has_many :users, through: :meetupowners

  validates :name, presence: true
  validates :location, presence: true
  validates :description, presence: true
  validates :date, presence: true
end
