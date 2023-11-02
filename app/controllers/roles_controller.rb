class RolesController < ApplicationController
  before_action :is_admin

  def index
    @roles = Role.all
  end

  def new
    @role = Role.new
  end

  def create
    @role = Role.new(role_params)
    if @role.save
      redirect_to roles_path, notice: "The role was created successfully."
    else
      render 'new'
    end
  end

  def assign_permissions
    @role = Role.find(params[:id])
    @permissions = Permission.all
  end

  def assign_permissions_patch
    @role = Role.find(params[:id])
    if @role.update(role_params)
      redirect_to roles_path, notice: "Permissions assigned to role successfully."
    else
      render 'assign_permissions'
    end
  end

  private

  def role_params
    params.require(:role).permit(:name, permission_ids: [])
  end
end
