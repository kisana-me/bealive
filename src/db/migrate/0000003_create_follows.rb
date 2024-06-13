class CreateFollows < ActiveRecord::Migration[7.0]
  def change
    create_table :follows do |t|
      t.bigint :followed_id, null: false, foreign_key: true
      t.bigint :follower_id, null: false, foreign_key: true
      t.string :uuid, null: false
      t.integer :status, limit: 1, null: false, default: 0
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
    add_foreign_key :follows, :accounts, column: :followed_id
    add_foreign_key :follows, :accounts, column: :follower_id
  end
end
