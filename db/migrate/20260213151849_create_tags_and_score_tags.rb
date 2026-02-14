class CreateTagsAndScoreTags < ActiveRecord::Migration[8.0]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.timestamps
    end
    add_index :tags, :name, unique: true

    create_table :score_tags do |t|
      t.references :score, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true
      t.timestamps
    end
    add_index :score_tags, [ :score_id, :tag_id ], unique: true
  end
end
