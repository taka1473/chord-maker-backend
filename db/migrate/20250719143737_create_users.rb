class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :account_id, null: false, index: { unique: true }
      t.timestamps
    end
  end
end
