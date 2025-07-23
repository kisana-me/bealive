class CreateGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :groups do |t|
      t.references :account, null: false, foreign_key: true
      t.string :aid, null: false
      t.string :name, null: false, default: ""
      t.text :description, null: false, default: ""
      t.json :meta, null: false, default: {}
      t.integer :status, limit: 1, null: false, default: 0
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
    add_index :groups, :aid, unique: true
  end
end
