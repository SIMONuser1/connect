class RegistrationsController < Devise::RegistrationsController
  skip_before_action :user_must_be_confirmed, only: [:new, :create, :destroy]
  skip_before_action :user_needs_business, only: [:new, :create, :destroy]
end
