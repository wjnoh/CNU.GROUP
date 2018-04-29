class CreateClassTimes < ActiveRecord::Migration[5.1]
  def change
    create_table :class_times do |t|
      t.belongs_to :classRoom
      t.string :dayAndTimeInterval

      t.timestamps
    end
  end
end
