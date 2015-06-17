class DropMeetupowners < ActiveRecord::Migration
  def up
    drop_table :meetup_owners
  end

  def down
    create_table "meetup_owners", force: true do |t|
      t.integer "user_id",   null: false
      t.integer "meetup_id", null: false
    end
  end
end
