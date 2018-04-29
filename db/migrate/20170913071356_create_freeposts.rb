class CreateFreeposts < ActiveRecord::Migration[5.1]
  def change
    create_table :freeposts do |t|
      t.belongs_to :user
      t.string :writer
      t.string :title
      t.string :content
      t.string :category

      t.timestamps
    end
  end
end
