class CreateTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token_type, null: false
      t.string :value, null: false
      t.datetime :expires_at, null: false
      t.datetime :revoked_at

      t.timestamps
    end
  end
end
