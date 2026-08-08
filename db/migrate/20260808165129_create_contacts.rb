class CreateContacts < ActiveRecord::Migration[8.0]
  def change
    create_table :contacts do |t|
      t.string :category, null: false
      t.text :body, null: false
      t.string :email
      t.string :score_url
      t.string :status, null: false, default: "open"

      t.timestamps
    end

    add_index :contacts, :status
  end
end
