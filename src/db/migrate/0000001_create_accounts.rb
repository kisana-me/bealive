class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.string :anyur_id, null: true
      t.string :anyur_access_token, null: false, default: ""
      t.string :anyur_refresh_token, null: false, default: ""
      t.datetime :anyur_token_fetched_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.string :aid, null: false, limit: 14
      t.string :name, null: false
      t.string :name_id, null: false
      t.bigint :icon_id, null: true
      t.text :description, null: false, default: ""
      t.datetime :birth, null: true
      t.string :email, null: false, default: ""
      t.boolean :email_verified, null: false, default: false
      t.string :password_digest, null: false, default: ""
      t.json :meta, null: false, default: {}
      t.integer :status, limit: 1, null: false, default: 0
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
    add_index :accounts, :anyur_id, unique: true
    add_index :accounts, :aid, unique: true
    add_index :accounts, :name_id, unique: true
  end
end
