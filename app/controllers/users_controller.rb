class UsersController < ApplicationController
  load_and_authorize_resource
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.all

  end

  def update
    puts "right here"
    @user.update(admin_params)
    redirect_to :back
  end


  private

  def set_user
    @user = User.find(params[:id])

  end

  def admin_params
    params.require(:user).permit(:admin, :need_admin_approval)
  end
end