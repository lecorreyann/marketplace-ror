class PermissionsController < ApplicationController
  def index
    @permissions = Permission.all
  end

  def new
    @permission = Permission.new
  end

  def create
    @permission = Permission.new(permission_params)
    if @permission.save
      redirect_to permissions_path, notice: "The permission was created successfully."
    else
      render 'new'
    end
  end

  private

  def permission_params
    params.require(:permission).permit(:name)
  end
end
