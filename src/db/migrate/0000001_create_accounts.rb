class CreateAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :accounts do |t|
      t.string :name, null: false
      t.string :name_id, null: false
      t.string :uuid, null: false
      t.text :description, null: false, default: ''
      t.datetime :birth, null: true
      t.string :email, null: false, default: ''
      t.string :phone, null: false, default: ''
      t.integer :status, limit: 1, null: false, default: 0
      t.boolean :deleted, null: false, default: false
      t.json :meta, null: false, default: {}
      t.string :password_digest, null: false, default: ''
      t.bigint :icon_id, null: true

      t.timestamps
    end
    add_index :accounts, [:name_id, :uuid], unique: true
  end
end
