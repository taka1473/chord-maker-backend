class ChangeColumnNameOrderToPosition < ActiveRecord::Migration[8.0]
  def change
    rename_column :chords, :order, :position
    rename_column :measures, :order, :position
  end
end
