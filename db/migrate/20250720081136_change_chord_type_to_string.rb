class ChangeChordTypeToString < ActiveRecord::Migration[8.0]
  def up
    change_column :chords, :type, :string, null: false
  end

  def down
    change_column :chords, :type, :integer, null: false
  end
end
