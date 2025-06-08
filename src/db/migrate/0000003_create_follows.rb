class CreateFollows < ActiveRecord::Migration[8.0]
  def change
    create_table :follows do |t|
      t.bigint :followed_id, null: false
      t.bigint :follower_id, null: false
      t.boolean :accepted, null: false, default: false

      t.timestamps
    end
    add_foreign_key :follows, :accounts, column: :followed_id
    add_foreign_key :follows, :accounts, column: :follower_id
    add_index :follows, [:followed_id, :follower_id], unique: true
  end
end
