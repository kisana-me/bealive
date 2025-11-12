class CreateGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :groups do |t|
      t.references :account, null: false, foreign_key: true
      t.references :icon, null: true, foreign_key: { to_table: :images }
      t.string :aid, null: false
      t.string :name, null: false, default: ""
      t.text :description, null: false, default: ""
      t.integer :visibility, null: false, limit: 1, default: 0
      t.json :meta, null: false, default: {}
      t.integer :status, limit: 1, null: false, default: 0

      t.timestamps
    end
    add_index :groups, :aid, unique: true
  end
end
