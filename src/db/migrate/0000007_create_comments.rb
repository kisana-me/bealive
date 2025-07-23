class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.references :account, null: true, foreign_key: true
      t.references :capture, null: false, foreign_key: true
      t.string :aid, null: false
      t.string :content, null: false
      t.json :meta, null: false, default: {}
      t.integer :status, limit: 1, null: false, default: 0
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
    add_index :comments, :aid, unique: true
  end
end
