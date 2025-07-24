class Additionals1 < ActiveRecord::Migration[7.1]
  def change
    # accounts
    add_column :accounts, :icon_id, :bigint, null: true
    add_foreign_key :accounts,  :images, column: :icon_id
    # groups
    add_column :groups, :icon_id, :bigint, null: true
    add_foreign_key :groups,  :images, column: :icon_id
    # captures
    add_column :captures, :front_photo_id, :bigint, null: true
    add_foreign_key :captures,  :images, column: :front_photo_id
    add_column :captures, :back_photo_id, :bigint, null: true
    add_foreign_key :captures,  :images, column: :back_photo_id
  end
end