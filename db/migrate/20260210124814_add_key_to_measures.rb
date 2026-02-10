class AddKeyToMeasures < ActiveRecord::Migration[8.0]
  def change
    add_column :measures, :key, :integer
    add_column :measures, :key_name, :string
  end
end
