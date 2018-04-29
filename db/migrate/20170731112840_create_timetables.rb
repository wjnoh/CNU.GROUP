class CreateTimetables < ActiveRecord::Migration[5.1]
  def change
    create_table :timetables do |t|
      t.belongs_to :user
      t.string :title
      t.boolean :main,        default: false
      t.timestamps
    end
  end
end
