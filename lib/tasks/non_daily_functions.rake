namespace :non_daily_functions do
  desc "Functions to be executed weekly/monthly/etc"

  task send_weekly_email: :environment do
    User.where(frequency: "weekly").map(&:send_email)
  end

  task send_monthly_email: :environment do
    User.where(frequency: "monthly").map(&:send_email)
  end
end
