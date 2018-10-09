class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]
  skip_before_action :user_must_be_confirmed, only: [:home]
  skip_before_action :user_needs_business, only: [:home, :welcome, :assign_business]

  def home
  end

  # def confirmation
  #   redirect_to welcome_path if current_user.confirmed?
  # end

  def welcome
    email_domain = current_user.email.match(/(?<=@).+/)[0]
    @user_business = Business.where(business_domain: email_domain).first
    redirect_to new_business_path if @user_business.nil?
  end

  def assign_business
    current_user.update!(business_id: params[:business])
    # current_user.business.update_suggestions!
    redirect_to suggestions_path
  end

  def search
    # @query = params[:filters][:query]
    @query = params[:query]
    @results = Business.search(@query, { facets: '*' })

  end

  # def domain_regex(url)
  #   url.match(/[http[s]?:\/\/]?(?:www\.)?([\w\-]*(?:\.[a-z\.]+))/i)[-1]
  # end
end
