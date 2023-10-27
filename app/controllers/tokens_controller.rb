class TokensController < ApplicationController

  def create_access_token(user:)
    # Check if user exists
    @user = User.find_by(email: user[:email])
    if @user.nil?
      raise RuntimeError, "User not found"
    else
      token = Token.new(user: user)
      token.token_type = :access
      token.value = SecureRandom.urlsafe_base64
      token.expires_at = Time.current + 15.minutes
      token.save
    end
    return token
  end

  def create_refresh_token(user:)
    # Check if user exists
    @user = User.find_by(email: user[:email])
    if @user.nil?
      raise RuntimeError, "User not found"
    else
      token = Token.new(user: user)
      token.token_type = :refresh
      token.value = SecureRandom.urlsafe_base64
      token.expires_at = Time.current + 15.minutes
      token.save
    end
    return token
  end

  def create_reset_password_token(user:)
    # Check if user exists
    @user = User.find_by(email: user[:email])
    if @user.nil?
      raise RuntimeError, "User not found"
    else
      token = Token.new(user: user)
      token.token_type = :reset_password
      token.value = SecureRandom.urlsafe_base64
      token.expires_at = Time.current + 15.minutes
      token.save
    end
    return token
  end

end
