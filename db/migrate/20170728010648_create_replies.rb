class CreateReplies < ActiveRecord::Migration[5.1]
  def change
    create_table :replies do |t|
      t.belongs_to :user
      t.belongs_to :post
      t.belongs_to :freepost
      t.belongs_to :adpost
      t.belongs_to :suggestionpost

      t.string :replyWriter
      t.text :replyContent

      t.timestamps
    end
  end
end
