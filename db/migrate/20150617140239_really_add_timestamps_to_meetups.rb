class ReallyAddTimestampsToMeetups < ActiveRecord::Migration
  def change
    add_column :meetups, :created_at, :datetime
    add_column :meetups, :updated_at, :datetime
  end
end
