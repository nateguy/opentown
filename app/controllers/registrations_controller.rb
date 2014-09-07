
class RegistrationsController < Devise::RegistrationsController


  private

  def sign_up_params
    params.require(:user).permit(:nickname, :first_name, :last_name, :location, :email, :password, :password_confirmation, :need_admin_approval)
  end

  def account_update_params
    params.require(:user).permit(:nickname, :first_name, :last_name, :location, :email, :password, :password_confirmation, :current_password, :need_admin_approval)
  end
end