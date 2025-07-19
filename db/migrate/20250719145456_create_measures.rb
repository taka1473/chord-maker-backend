class CreateMeasures < ActiveRecord::Migration[8.0]
  def change
    create_table :measures do |t|
      t.references :score, null: false, foreign_key: true
      t.integer :order, null: false
      t.timestamps
    end
  end
end
