class SetDefaultForOwnersInMeetupAttendees < ActiveRecord::Migration
  def up
    change_column :meetup_attendees, :owner, :boolean, default: false
  end
  def down
    change_column :meetup_attendees, :owner, :boolean
  end
end
