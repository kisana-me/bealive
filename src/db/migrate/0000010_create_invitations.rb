class CreateInvitations < ActiveRecord::Migration[7.1]
  def change
    create_table :invitations do |t|
      t.references :account, null: false, foreign_key: true
      t.string :uuid, null: false
      t.string :name, null: false, default: ''
      t.string :code, null: false, default: ''
      t.integer :uses, null: false, default: 0
      t.integer :max_uses, null: false, default: 1
      t.datetime :expires_at
      t.integer :status, limit: 1, null: false, default: 0
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
    add_index :invitations, :uuid, unique: true
    add_index :invitations, :code, unique: true
  end
end
