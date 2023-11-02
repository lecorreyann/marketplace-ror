module AuthHelper
  def is_admin?
    @current_user && (@current_user.has_role?('admin') || @current_user.has_permission('*'))
  end

  def is_logged?
    @current_user.present?
  end
end
