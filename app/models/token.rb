# app/models/token.rb
class Token < ApplicationRecord
  belongs_to :user

  validates :token_type, presence: true
  validates :value, presence: true
  validates :expires_at, presence: true

  enum :token_type => {
    "email_validation" => "email_validation",
    "access" => "access",
    "refresh" => "refresh",
    "reset_password" => "reset_password"
  }
  validates :token_type, inclusion: { in: Token.token_types.keys }
end
