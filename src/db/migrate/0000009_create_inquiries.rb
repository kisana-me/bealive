class CreateInquiries < ActiveRecord::Migration[7.1]
  def change
    create_table :inquiries do |t|
      t.string :uuid, null: false
      t.string :subject, null: false, default: ''
      t.text :content, null: false, default: ''
      t.string :name, null: false, default: ''
      t.string :address, null: false, default: ''
      t.text :memo, null: false, default: ''
      t.json :meta, null: false, default: {}
      t.integer :status, limit: 1, null: false, default: 0
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
    add_index :inquiries, :uuid, unique: true
  end
end
