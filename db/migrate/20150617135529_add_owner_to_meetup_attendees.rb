class AddOwnerToMeetupAttendees < ActiveRecord::Migration
  def change
    add_column :meetup_attendees, :owner, :boolean
  end
end
