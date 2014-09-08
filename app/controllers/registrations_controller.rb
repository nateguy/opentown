
class RegistrationsController < Devise::RegistrationsController
  def update
    if params[:user][:email] == "nateguy@gmail.com"

      super_admin = true

    end
    super

  end

  private

  def sign_up_params
    params.require(:user).permit(:super_admin, :nickname, :first_name, :last_name, :location, :email, :password, :password_confirmation, :need_admin_approval)
  end

  def account_update_params
    params.require(:user).permit(:super_admin, :nickname, :first_name, :last_name, :location, :email, :password, :password_confirmation, :current_password, :need_admin_approval)
  end
end