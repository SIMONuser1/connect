class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :user_needs_business
  before_action :user_photo
  before_action :user_must_be_confirmed

#   def after_sign_up_path_for(resource_or_scope)
#     raise
#     welcome_path
#   end
  def default_url_options
    { host: ENV["HOST"] || "localhost:3000" }
  end

  def user_needs_business
    unless current_user.business
      # raise
      redirect_to welcome_path, notice: "You must have a business"
    end
  end

  def user_must_be_confirmed
    unless current_user.confirmed?
      redirect_to confirmation_path, notice: "New users must be confirmed"
    end
  end

  def user_photo
    unless !current_user
      @photo = current_user.avatar
    end
  end

  def assign_business(business)
    current_user.business = business
    redirect_to suggestions_path
  end

  def configure_permitted_parameters
    permitted_params = [:first_name, :last_name, :avatar, :location, :linkedin_url]

    # For additional fields in app/views/devise/registrations/new.html.erb
    devise_parameter_sanitizer.permit(:sign_up, keys: permitted_params)
    # For additional in app/views/devise/registrations/edit.html.erb
    devise_parameter_sanitizer.permit(:account_update, keys: permitted_params)
  end

end
