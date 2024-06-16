class Additionals1 < ActiveRecord::Migration[7.1]
  def change
    # accounts
    add_column :accounts, :icon_id, :bigint, null: true
    add_column :accounts, :invitation_id, :bigint, null: true
    add_foreign_key :accounts,  :images, column: :icon_id
    add_foreign_key :accounts,  :invitations, column: :invitation_id
    # groups
    add_column :groups, :icon_id, :bigint, null: true
    add_foreign_key :groups,  :images, column: :icon_id
  end
end