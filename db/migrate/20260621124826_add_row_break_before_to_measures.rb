class AddRowBreakBeforeToMeasures < ActiveRecord::Migration[8.0]
  def change
    add_column :measures, :row_break_before, :boolean, default: false, null: false
  end
end
