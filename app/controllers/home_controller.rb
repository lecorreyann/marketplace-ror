class HomeController < ApplicationController
  before_action :set_current_user
  before_action :valid_token

  def index
    render :index
  end

  private

  def set_current_user
    # Set the current user instance variable and join access and refresh token if the user is logged in
    if session[:user_id].present?
      @current_user = User.find(session[:user_id])
      @access_token = Token.where(user: @current_user, token_type: :access).last&.value
      @refresh_token = Token.where(user: @current_user, token_type: :refresh).last&.value
    end
  end

  def valid_token
    # Check if access token and refresh token are present
    if @access_token.nil? || @refresh_token.nil?
      # No access token or refresh token, redirect to sign in page
      return redirect_to users_sign_in_path
    end

    # Check if access token is expired
    access_token = Token.where(user: @current_user, token_type: :access).last
    if access_token.expires_at < Time.current
      # Access token is expired, revoke token and check refresh token
      access_token.revoked_at = Time.current
      access_token.save
      # Check if refresh token is expired
      refresh_token = Token.where(user: @current_user, token_type: :refresh).last
      if refresh_token.expires_at < Time.current
        # Refresh token is expired, revoke token and redirect to sign in page
        refresh_token.revoked_at = Time.current
        refresh_token.save
        return redirect_to users_sign_in_path
      else
        # Create new access token
        tokens_controller = TokensController.new
        access_token = tokens_controller.create_access_token(user: @current_user)
        @access_token = access_token.value
      end
    end


  end
end
