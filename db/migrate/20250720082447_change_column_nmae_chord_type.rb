class ChangeColumnNmaeChordType < ActiveRecord::Migration[8.0]
  def change
    # type is a reserved word in Rails
    rename_column :chords, :type, :chord_type
  end
end
