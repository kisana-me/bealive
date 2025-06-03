class CreateSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :sessions do |t|
      t.references :account, null: false, foreign_key: true
      t.string :lookup, null: false
      t.string :digest, null: false
      t.string :name, null: false, default: ''
      t.string :user_agent, null: false, default: ""
      t.string :ip_address, null: false, default: ""
      t.datetime :expires_at
      t.datetime :generated_at
      t.json :meta, null: false, default: {}
      t.integer :status, limit: 1, null: false, default: 0
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
    add_index :sessions, :lookup, unique: true
  end
end
