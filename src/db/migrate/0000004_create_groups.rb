class CreateGroups < ActiveRecord::Migration[7.1]
  def change
    create_table :groups do |t|
      t.references :account, null: false, foreign_key: true
      t.string :uuid, null: false
      t.string :name, null: false, default: ''
      t.integer :status, limit: 1, null: false, default: 0
      t.json :meta, null: false, default: {}
      t.boolean :deleted, null: false, default: false
      t.bigint :icon_id, null: true

      t.timestamps
    end
  end
end
