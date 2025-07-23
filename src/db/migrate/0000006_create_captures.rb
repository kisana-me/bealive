class CreateCaptures < ActiveRecord::Migration[8.0]
  def change
    create_table :captures do |t|
      t.string :aid, null: false, limit: 14
      t.bigint :sender_id, null: false
      t.bigint :receiver_id, null: true
      t.bigint :sender_capture_id, null: true
      t.references :group, null: true, foreign_key: true
      t.string :front_original_key, null: false, default: ""
      t.string :front_variants, null: false, default: ""
      t.string :back_original_key, null: false, default: ""
      t.string :back_variants, null: false, default: ""
      t.boolean :reversed, null: false, default: false
      t.decimal :latitude, null: true
      t.decimal :longitude, null: true
      t.string :comment, null: false, default: ""
      t.datetime :captured_at, null: true
      t.integer :visibility, limit: 1, null: false, default: 0
      t.json :meta, null: false, default: {}
      t.integer :status, limit: 1, null: false, default: 0
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
    add_foreign_key :captures, :accounts, column: :sender_id
    add_foreign_key :captures, :accounts, column: :receiver_id
    add_foreign_key :captures, :captures, column: :sender_capture_id
    add_index :captures, :aid, unique: true
  end
end
