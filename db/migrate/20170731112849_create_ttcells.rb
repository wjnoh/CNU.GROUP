class CreateTtcells < ActiveRecord::Migration[5.1]
  def change
    create_table :ttcells do |t|
      t.integer :timetable_id
      t.string :cellId
      t.string :cellName
      t.integer :rowSpan
      t.integer :colSpan
      t.string :cellColor
      t.timestamps
    end
  end
end
