class ApplicationController < ActionController::Base
  include Authentication
  include AuthHelper
  before_action :set_current_user
  before_action :valid_token

  private




end
