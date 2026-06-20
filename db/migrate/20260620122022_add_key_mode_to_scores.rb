class AddKeyModeToScores < ActiveRecord::Migration[8.0]
  def change
    add_column :scores, :key_mode, :string, null: false, default: "major"
  end
end
