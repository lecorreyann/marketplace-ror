class HomeController < ApplicationController
  before_action :set_current_user

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
end
