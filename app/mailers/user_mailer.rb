class UserMailer < Devise::Mailer
  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  default template_path: 'devise/mailer' # to make sure that your mailer uses the devise views

  default :from => "blake.rowley@aiime.io"

  # Below is saved in case we need to revert to the 'postmark' gem instead of 'postmark-rails'
  # CLIENT = Postmark::ApiClient.new(ENV['postmark_api_key'])

  def welcome_email
    # call this function by: UserMailer.with(user: user).welcome_email.deliver_now
    @user =  params[:user]
    @url  = 'http://www.aiime.io'
    mail(to: 'thiswontwork@aiime.io', subject: 'Welcome to My Awesome Site')
  end

  def daily_suggestions

  end

  def weekly_suggestions

  end

  def monthly_suggestions

  end

  def check_bounced_emails
    client = postmark_client

    User.all.each do |user|
      next unless client.bounces(type: 'HardBounce', emailFilter: user.email).first
      user.unconfirm
    end
  end

  private
  def postmark_client
    Postmark::ApiClient.new(ActionMailer::Base.postmark_settings[:api_key])
  end
end
