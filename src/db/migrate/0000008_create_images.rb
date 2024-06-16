class CreateImages < ActiveRecord::Migration[7.1]
  def change
    create_table :images do |t|
      t.references :account, null: true, foreign_key: true
      t.string :uuid, null: false
      t.string :name, null: false, default: ''
      t.datetime :expires_at
      t.string :original_key, null: false, default: ''
      t.string :variants, null: false, default: ''
      t.integer :status, limit: 1, null: false, default: 0
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
    add_index :images, :uuid, unique: true
  end
end
