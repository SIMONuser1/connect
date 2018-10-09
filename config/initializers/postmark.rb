  Rails.application.configure do
    # ...
    config.action_mailer.delivery_method     = :postmark
    config.action_mailer.postmark_settings   = { api_key: ENV["postmark_api_token"] }
    config.action_mailer.default_url_options = { host: "www.aiime.io" }
    # or your custom domain name eg. "www.yourdomain.com"
  end

