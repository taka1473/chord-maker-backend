class ChangeScoresKeyToInteger < ActiveRecord::Migration[8.0]
  def up
    change_column :scores, :key, :integer, null: false, using: 'key::integer', comment: '0: A, 1: A#, 2: B, 3: C, 4: C#, 5: D, 6: D#, 7: E, 8: F, 9: F#, 10: G, 11: G#'
    add_column :scores, :key_name, :string, null: false, comment: 'distinguishing A# from Bb'
  end

  def down
    change_column :scores, :key, :string
  end
end
