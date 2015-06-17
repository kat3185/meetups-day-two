class Meetup < ActiveRecord::Base
  has_many :meetup_attendees
  has_many :users, through: :meetup_attendees

  validates :name, presence: true
  validates :location, presence: true
  validates :description, presence: true
  validates :date, presence: true
end
