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

  private

  def user_params
    params.require(:user).permit(:role_ids)
  end


end
