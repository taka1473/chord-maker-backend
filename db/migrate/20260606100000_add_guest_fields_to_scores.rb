class AddGuestFieldsToScores < ActiveRecord::Migration[8.0]
  def change
    change_column_null :scores, :user_id, true
    add_column :scores, :guest_token, :string
    add_column :scores, :guest_expires_at, :datetime
    add_index :scores, :guest_token, unique: true
  end
end
