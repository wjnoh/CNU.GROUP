class CreateApplies < ActiveRecord::Migration[5.1]
  def change
    create_table :applies do |t|
      t.belongs_to :board
      t.belongs_to :user
      t.text :message

      t.timestamps
    end
  end
end
