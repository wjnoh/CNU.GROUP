class CreateColleges < ActiveRecord::Migration[5.1]
  def change
    create_table :colleges do |t|
      t.string :collegeName
      
      t.timestamps
    end
  end
end
