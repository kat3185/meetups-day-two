class RemoveDateFromMeetups < ActiveRecord::Migration
  def change
    remove_column :meetups, :date, :integer
  end
end
