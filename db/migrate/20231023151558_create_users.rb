class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, index: { unique: true }, null: false
      t.string :password_digest, null: false

      t.timestamps
    end
  end
end
