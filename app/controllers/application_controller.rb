class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :set_current_user

  before_filter do
    resource =
  controller_name.singularize.to_sym
      method = "#{resource}_params"
      params[resource] &&=
  send(method) if
  respond_to?(method, true)
  end

  def set_current_user
    User.current = current_user
  end

end
