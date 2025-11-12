class CreateCaptures < ActiveRecord::Migration[8.0]
  def change
    create_table :captures do |t|
      t.string :aid, null: false, limit: 14
      t.references :sender, null: false, foreign_key: { to_table: :accounts }
      t.references :receiver, null:true, foreign_key: { to_table: :accounts }
      t.references :parent_capture, null: true, foreign_key: { to_table: :captures }
      t.references :group, null: true, foreign_key: true
      t.references :main_photo, null: true, foreign_key: { to_table: :images }
      t.references :sub_photo, null: true, foreign_key: { to_table: :images }
      t.decimal :latitude, null: true
      t.decimal :longitude, null: true
      t.string :sender_comment, null: true
      t.string :receiver_comment, null: true
      t.datetime :captured_at, null: true
      t.integer :visibility, limit: 1, null: false, default: 0
      t.json :meta, null: false, default: {}
      t.integer :status, limit: 1, null: false, default: 0

      t.timestamps
    end
    add_index :captures, :aid, unique: true
  end
end
