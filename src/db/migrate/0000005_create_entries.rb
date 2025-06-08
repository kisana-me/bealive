class CreateEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :entries do |t|
      t.references :account, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true
      t.integer :status, limit: 1, null: false, default: 0

      t.timestamps
    end
    add_index :entries, [:account_id, :group_id], unique: true
  end
end
