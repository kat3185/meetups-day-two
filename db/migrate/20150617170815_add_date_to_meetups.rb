class AddDateToMeetups < ActiveRecord::Migration
  def change
    add_column :meetups, :date, :integer
  end
end
