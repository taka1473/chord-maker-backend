class AddSlugToScores < ActiveRecord::Migration[8.0]
  def up
    add_column :scores, :slug, :string

    Score.reset_column_information
    Score.find_each do |score|
      base = score.title.parameterize.presence || "score"
      loop do
        candidate = "#{base}-#{SecureRandom.alphanumeric(6).downcase}"
        unless Score.exists?(slug: candidate)
          score.update_column(:slug, candidate)
          break
        end
      end
    end

    change_column_null :scores, :slug, false
    add_index :scores, :slug, unique: true
  end

  def down
    remove_index :scores, :slug
    remove_column :scores, :slug
  end
end
