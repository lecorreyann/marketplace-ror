class AddEmailValidatedAtToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :email_validated_at, :datetime
  end
end
