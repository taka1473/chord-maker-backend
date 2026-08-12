class AddTensionsToChords < ActiveRecord::Migration[8.0]
  def change
    add_column :chords, :tensions, :json, null: false, default: []
  end
end
