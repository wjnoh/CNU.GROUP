class CreateAcceptApplies < ActiveRecord::Migration[5.1]
  def change
    create_table :accept_applies do |t|
      t.belongs_to :user
      t.belongs_to :board

      t.timestamps
    end
  end
end
