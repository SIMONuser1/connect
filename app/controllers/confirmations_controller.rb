class ConfirmationsController < Devise::ConfirmationsController
  skip_before_action :user_must_be_confirmed
  skip_before_action :user_needs_business
  private
  def after_confirmation_path_for(resource_name, resource)
    welcome_path
  end
end
