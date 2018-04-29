class CreateClassRooms < ActiveRecord::Migration[5.1]
  def change
    create_table :class_rooms do |t|
      t.belongs_to :college
      t.string :classRoomName

      t.timestamps
    end
  end
end
