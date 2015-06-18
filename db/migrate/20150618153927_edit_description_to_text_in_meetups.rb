class EditDescriptionToTextInMeetups < ActiveRecord::Migration
  def up
    change_column :meetups, :description, :text, null: false
  end
  def down
    change_column :meetups, :description, :string, null:false
  end
end
