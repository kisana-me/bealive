class CreateCaptures < ActiveRecord::Migration[8.0]
  def change
    create_table :captures do |t|
      t.string :aid, null: false, limit: 14
      t.bigint :sender_id, null: false
      t.bigint :receiver_id, null: true
      t.bigint :parent_capture_id, null: true
      t.references :group, null: true, foreign_key: true
      t.bigint :front_photo_id, null: true
      t.bigint :back_photo_id, null: true
      t.boolean :reversed, null: false, default: false
      t.decimal :latitude, null: true
      t.decimal :longitude, null: true
      t.string :sender_comment, null: false, default: ""
      t.string :receiver_comment, null: false, default: ""
      t.datetime :captured_at, null: true
      t.integer :visibility, limit: 1, null: false, default: 0
      t.json :meta, null: false, default: {}
      t.integer :status, limit: 1, null: false, default: 0
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
    add_index :captures, :aid, unique: true
    add_index :captures, :sender_id, unique: false
    add_index :captures, :receiver_id, unique: false
    add_index :captures, :parent_capture_id, unique: false
    add_index :captures, :front_photo_id, unique: false
    add_index :captures, :back_photo_id, unique: false
    add_foreign_key :captures, :accounts, column: :sender_id
    add_foreign_key :captures, :accounts, column: :receiver_id
    add_foreign_key :captures, :captures, column: :parent_capture_id
    add_foreign_key :captures, :images, column: :front_photo_id
    add_foreign_key :captures, :images, column: :back_photo_id
  end
end
