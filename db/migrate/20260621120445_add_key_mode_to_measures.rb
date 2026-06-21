class AddKeyModeToMeasures < ActiveRecord::Migration[8.0]
  def change
    add_column :measures, :key_mode, :string
  end
end
