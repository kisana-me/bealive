class CreateInvitations < ActiveRecord::Migration[7.1]
  def change
    create_table :invitations do |t|
      t.string :uuid
      t.string :name
      t.string :code
      t.integer :uses
      t.integer :max_uses
      t.datetime :expires_at
      t.boolean :deleted

      t.timestamps
    end
  end
end
