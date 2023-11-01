class UsersController < ApplicationController

  def index
    @users = User.all
  end

  def assign_role
    @user = User.find(params[:id])
    @roles = Role.all
  end

  def assign_role_patch
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to users_path, notice: "Role assigned to user successfully."
    else
      render 'assign_role'
    end
  end

  def sign_in_show
    @user = User.new
    render 'users/auth/sign_in'
  end

  def sign_in_post
    # Find the user by email with access token_type access and refresh token
    @user = User.find_by(email: params[:user][:email])

    # Check if user exists
    if @user.nil?
      # User does not exist, render add error to email field
      @user ||= User.new(email: params[:user][:email])
      @user.errors.add(:email, "not found")
      return render 'users/auth/sign_in', status: :unprocessable_entity
    end

    # Check if user's password is incorrect
    if !@user.authenticate(params[:user][:password])
      @user.errors.add(:password, "is incorrect")
      return render 'users/auth/sign_in', status: :unprocessable_entity
    end

    # Check if user's email has been validated
    if @user.email_validated_at.nil?
      # User's email has not been validated, render
      return render 'users/auth/email_validation/email_not_validated', status: :unprocessable_entity
    end

    # Check user's access token
    tokens_controller = TokensController.new
    last_access_token = Token.where(user: @user, token_type: :access).last
    if last_access_token.nil? || last_access_token.expires_at < Time.current
      # Create access token
      access_token = tokens_controller.create_access_token(user: @user)
    end

    # Check user's refresh token
    last_refresh_token = Token.where(user: @user, token_type: :refresh).last
    if last_refresh_token.nil? || last_refresh_token.expires_at < Time.current
      # Create refresh token
      refresh_token = tokens_controller.create_refresh_token(user: @user)
    end

    # Start session
    session[:user_id] = @user.id
    return redirect_to root_path, notice: "Login successful and redirected to the home page"

  end

  def sign_up_show
    @user = User.new
    render 'users/auth/sign_up/sign_up'
  end

  def sign_up_post
    @user = User.new(user_params) # Build a new User instance from form parameters

    if @user.save
      # User registration was successful
      render 'users/auth/sign_up/sign_up_confirmation', status: :created
    else
      # User registration failed, re-render the registration form
      render 'users/auth/sign_up/sign_up', status: :unprocessable_entity
    end
  end

  def sign_out
    # Find the user by the session user id
    @user = User.find(session[:user_id])
    # Find the user's access token
    token = Token.where(user: @user, token_type: :access).last
    # Revoke the user's access token
    token.revoked_at = Time.current
    token.save
    # Delete the user's session
    session.delete(:user_id)
    # Redirect to the home page
    redirect_to root_path, notice: "You have been signed out"
  end

  def validate_email
    # Find the user by the email validation token
    @user = User.joins(:tokens).find_by(tokens: { value: params[:token], token_type: :email_validation })

    # Check if user exists
    if @user.nil?
      # User does not exist, render
      return render 'users/auth/email_validation/email_validation_token_not_found', status: :unprocessable_entity
    end
    # Check if email has already been validated
    if @user.email_validated_at.present?
      # Email has already been validated, render
      return render 'users/auth/email_validation/email_already_validated', status: :unprocessable_entity
    end
    token = @user.tokens.first
    # Check if token is revoked
    if token.revoked_at.present?
      # Token is revoked, render
      return render 'users/auth/email_validation/validation_email_token_revoked', status: :unprocessable_entity
    end
    # Check if token is expired
    if token.expires_at < Time.current
      # Token is expired, create new token for the user
      token = Token.new(user: @user)
      token.token_type = :email_validation
      token.value = SecureRandom.urlsafe_base64
      token.expires_at = Time.current + 24.hours
      token.save
      # Send the user a new email validation email
      UserMailer.with(user: @user, token: token).email_validation.deliver_later
      render 'users/auth/email_validation/validation_email_token_expired', status: :unprocessable_entity
    # Token is valid
    else
      # Token is valid, update the user's email validation status
      @user.email_validated_at = Time.current
      if @user.save
        render 'users/auth/email_validation/email_validated', status: :ok
      else
        puts @user.errors.full_messages
      end
    end
  end

  def forgot_password_show
    @user = User.new
    render 'users/auth/forgot_password/forgot_password'
  end

  def forgot_password_post
    # Find the user by email with access token_type access and refresh token
    @user = User.find_by(email: params[:user][:email])

    # Check if user exists
    if @user.nil?
      # User does not exist, render add error to email field
      @user ||= User.new(email: params[:user][:email])
      @user.errors.add(:email, "not found")
      return render 'users/auth/forgot_password/forgot_password', status: :unprocessable_entity
    end

    # Check user's reset password token
    tokens_controller = TokensController.new
    last_reset_password_token = Token.where(user: @user, token_type: :reset_password).last
    if last_reset_password_token.nil? || last_reset_password_token.expires_at < Time.current
      # Create reset password token
      last_reset_password_token = tokens_controller.create_reset_password_token(user: @user)
    end

    # Send the user a reset password email
    UserMailer.with(user: @user, token: last_reset_password_token).reset_password.deliver_later

    # Render the forgot password confirmation page
    render 'users/auth/forgot_password/forgot_password_confirmation', status: :accepted
  end

  def reset_password_show
    # Check if reset password token is valid
    if self.valid_reset_password_token?(token: params[:token])== true
    # Render the reset password page
      render 'users/auth/reset_password/reset_password'
    end
  end

  def reset_password_patch

    if self.valid_reset_password_token?(token:params[:user][:reset_password_token]) == true
      # Check if password and password confirmation match
      # puts >>> USER with red color
      # Revoke the user's reset password token
      last_reset_password_token = Token.find_by(tokens: { value: params[:user][:reset_password_token], token_type: :reset_password, user: @user })
      last_reset_password_token.revoked_at = Time.current
      last_reset_password_token.save
      if @user && @user.update(user_params)
        # Password reset successful
        return render 'users/auth/reset_password/password_reseted', status: :accepted
      else
        puts @user.errors.full_messages
      end
    end
  end

  def valid_reset_password_token?(token:)
    # Check if reset password token is valid
    @user = User.joins(:tokens).find_by(tokens: { value: token, token_type: :reset_password })

    # Check if user exists
    if @user.nil?
      # User does not exist, render
      return render 'users/auth/reset_password/reset_password_token_not_found', status: :unprocessable_entity
    end

    tokens_controller = TokensController.new
    last_reset_password_token = Token.where(user: @user, value: token, token_type: :reset_password).last
    # Check if reset password token is expired
    if last_reset_password_token.expires_at < Time.current
      # Reset password token is expired, render
      return render 'users/auth/reset_password/reset_password_token_expired', status: :unprocessable_entity
    end

    # Check if reset password token is revoked
    if last_reset_password_token.revoked_at.present?
      # Reset password token is revoked, render
      return render 'users/auth/reset_password/reset_password_token_revoked', status: :unprocessable_entity
    end
    return true
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :reset_password_token, :role_ids)
  end


end
