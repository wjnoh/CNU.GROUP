class CreateNotices < ActiveRecord::Migration[5.1]
  def change
    create_table :notices do |t|
      t.belongs_to :user
      t.string :message

      t.timestamps
    end
  end
end
