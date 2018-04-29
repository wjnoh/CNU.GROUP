class CreatePosts < ActiveRecord::Migration[5.1]
  def change
    create_table :posts do |t|
      t.belongs_to :user   # 게시글 삭제권한을 주기 위한 column
      t.belongs_to :board
      t.string :modifyFileName
      t.string :originalFileName
      t.string :writer
      t.string :title
      t.text :content
      t.boolean :notice,              default: false
      t.boolean :info,                default: false

      t.timestamps
    end
  end
end
