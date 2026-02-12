class AddArtistToScores < ActiveRecord::Migration[8.0]
  def change
    add_column :scores, :artist, :string
  end
end
