class ChangeColumnAllowNullOfScoresTempo < ActiveRecord::Migration[8.0]
  def change
    change_column_null :scores, :tempo, true
    change_column_null :scores, :time_signature, true
    change_column_comment :scores, :key, from: "0: A, 1: A#, 2: B, 3: C, 4: C#, 5: D, 6: D#, 7: E, 8: F, 9: F#, 10: G, 11: G#", to: "0: A, 1: A#..."
  end
end
