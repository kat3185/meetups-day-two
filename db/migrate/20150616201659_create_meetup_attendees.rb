class CreateMeetupAttendees < ActiveRecord::Migration
  def change
    create_table :meetup_attendees do |t|
      t.integer :user_id, null: false
      t.integer :meetup_id, null: false
    end
  end
end
