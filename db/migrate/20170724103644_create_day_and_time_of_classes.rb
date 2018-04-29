class CreateDayAndTimeOfClasses < ActiveRecord::Migration[5.1]
  def change
    create_table :day_and_time_of_classes do |t|
      t.belongs_to :classTime
      t.string :day
      t.string :time

      t.timestamps
    end
  end
end
