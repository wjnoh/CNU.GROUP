class CreateBoards < ActiveRecord::Migration[5.1]
  def change
    create_table :boards do |t|
      t.belongs_to :user   
      t.string :title
      t.string :info
      t.string :category
      t.integer :memberCount
      t.integer :totalNumberOfMember

      t.timestamps
    end
  end
end
