class CreateScores < ActiveRecord::Migration[8.0]
  def change
    create_table :scores do |t|
      t.string :title, null: false
      t.references :user, null: false, foreign_key: true
      t.boolean :published, default: false
      t.integer :tempo, null: false
      t.string :key, null: false
      t.string :time_signature, null: false
      t.text :lyrics
      t.timestamps
    end
  end
end
