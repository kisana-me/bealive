class CreateEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :entries do |t|
      t.references :account, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true
      t.string :uuid, null: false
      t.integer :status, limit: 1, null: false, default: 0
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
  end
end
