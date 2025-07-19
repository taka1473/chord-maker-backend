class CreateChords < ActiveRecord::Migration[8.0]
  def change
    create_table :chords do |t|
      t.references :measure, null: false, foreign_key: true
      t.integer :order, null: false
      t.integer :root_offset, null: false
      t.integer :bass_offset, null: false
      t.integer :type, null: false, default: 0
      t.timestamps
    end
  end
end
