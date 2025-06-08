class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.references :account, null: true, foreign_key: true
      t.references :capture, null: false, foreign_key: true
      t.string :uuid, null: false
      t.string :content, null: false
      t.integer :status, limit: 1, null: false, default: 0
      t.json :meta, null: false, default: {}

      t.timestamps
    end
    add_index :comments, :uuid, unique: true
  end
end
