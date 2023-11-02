class User < ApplicationRecord
  has_secure_password
  acts_as_paranoid
  # User has many token
  has_many :tokens, dependent: :destroy

  validates :first_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :first_name, format: { with: /\A[\p{L}' -]+\z/ }
  validates :last_name, presence: true, length: { minimum: 2, maximimum: 50 }
  validates :last_name, format: { with: /\A[\p{L}' -]+\z/}
  validates :email, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 8, maximum: 50 }, if: :password_changed?

  after_create :generate_email_validation_token

  # User has many roles through user_roles
  has_many :user_roles
  has_many :roles, through: :user_roles
  has_many :role_permissions, through: :roles
  has_many :permissions, through: :role_permissions

  attr_accessor :reset_password_token

  def has_role?(role_name)
    roles.exists?(name: role_name)
  end

  def has_permission?(permission_name)
    permissions.exists(name: permission_name)
  end

  private

  def generate_email_validation_token
    # find or initialize a token type email_validation
    token = Token.find_or_initialize_by(user: self, token_type: :email_validation)

    if token.new_record?
      token.token_type = :email_validation
      token.value = SecureRandom.urlsafe_base64
      token.expires_at = Time.current + 24.hours
      if token.valid?
        token.save
        # Send email validation email
        UserMailer.with(user: self, token: token).email_validation.deliver_later
      else
        puts token.errors.full_messages
      end
    end
  end

  def password_changed?
    password.present? || password_digest_changed?
  end


end
