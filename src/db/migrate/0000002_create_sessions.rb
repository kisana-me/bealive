class CreateSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :sessions do |t|
      t.references :account, null: false, foreign_key: true
      t.string :token_lookup, null: false
      t.string :token_digest, null: false
      t.datetime :token_expires_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.datetime :token_generated_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.string :name, null: false, default: ""
      t.string :user_agent, null: false, default: ""
      t.string :ip_address, null: false, default: ""
      t.json :meta, null: false, default: {}
      t.integer :status, limit: 1, null: false, default: 0
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
    add_index :sessions, :token_lookup, unique: true
  end
end
