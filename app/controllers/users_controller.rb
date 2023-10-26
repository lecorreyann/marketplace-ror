class UsersController < ApplicationController

  def sign_in_show
    @user = User.new
    render 'users/auth/sign_in'
  end

  def sign_in_post
    @user = User.new
    puts params.inspect
    # Find the user by email
    @user = User.find_by(email: params[:user][:email])
    # Check if user exists
    if @user.nil?
      # User does not exist, render add error to email field
      @user ||= User.new(email: params[:user][:email])
      @user.errors.add(:email, "not found")
      return render 'users/auth/sign_in', status: :unprocessable_entity
    end
    # Check if user's password is correct
    if @user.authenticate(params[:user][:password])
      # User's password is correct
      # Check if user's email has been validated
      if @user.email_validated_at.nil?
        # User's email has not been validated, render
        return render 'users/email_validation/email_not_validated', status: :unprocessable_entity
      end
      # User's email has been validated
      # Create access token
      token = Token.new(user: @user)
      token.token_type = :access
      token.value = SecureRandom.urlsafe_base64
      token.expires_at = Time.current + 15.minutes
      token.save
      # Create refresh token
      token = Token.new(user: @user)
      token.token_type = :refresh
      token.value = SecureRandom.urlsafe_base64
      token.expires_at = Time.current + 7.days
      token.save
      # Start session
      session[:user_id] = @user.id
      return redirect_to root_path, notice: "Login successful and redirected to the home page"
    else
      # User's password is incorrect, render
      @user.errors.add(:password, "is incorrect")
      return render 'users/auth/sign_in', status: :unprocessable_entity
    end

  end

  def sign_up_show
    @user = User.new
    render 'users/auth/sign_up'
  end

  def sign_up_post
    @user = User.new(user_params) # Build a new User instance from form parameters

    if @user.save
      # User registration was successful
      render 'users/auth/sign_up_confirmation', status: :created
    else
      # User registration failed, re-render the registration form
      render 'users/auth/sign_up', status: :unprocessable_entity
    end
  end

  def validate_email
    # Find the user by the email validation token
    @user = User.joins(:tokens).find_by(tokens: { value: params[:token], token_type: :email_validation })

    # Check if user exists
    if @user.nil?
      # User does not exist, render
      return render 'users/email_validation/email_validation_token_not_found', status: :unprocessable_entity
    end
    # Check if email has already been validated
    if @user.email_validated_at.present?
      # Email has already been validated, render
      return render 'users/email_validation/email_already_validated', status: :unprocessable_entity
    end
    token = @user.tokens.first
    # Check if token is revoked
    if token.revoked_at.present?
      # Token is revoked, render
      return render 'users/email_validation/validation_email_token_revoked', status: :unprocessable_entity
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
      render 'users/email_validation/validation_email_token_expired', status: :unprocessable_entity
    # Token is valid
    else
      # Token is valid, update the user's email validation status
      @user.email_validated_at = Time.current
      if @user.save
        render 'users/email_validation/email_validated', status: :ok
      else
        puts @user.errors.full_messages
      end
    end
  end


  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end


end
