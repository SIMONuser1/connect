namespace :daily_functions do
  desc "Functions to be executed daily"

  task update_daily_suggestions: :environment do
    User.all.map(&:get_daily_suggestion)
  end

  task check_for_text_businesses: :environment do
    # Update any other_competitors which are now real businesses
    Business.where.not(other_competitors: []).each do |bus|
      bus.other_competitors.each do |comp|
        if comp_bus = Business.find_by(name: comp)
          bus.competitions.create(competitor: comp_bus)
          bus.other_competitors -= [comp]
          bus.save
        end
      end
    end

    # Update any other_partners which are now real businesses
    Business.where.not(other_partners: []).each do |bus|
      acquired = false
      bus.other_partners.each do |partner|
        if  partner[-6..-1] == " (acq)"
          p_name = partner[0..-7]
          acquired = true
        elsif partner[-6..-1] == " (des)"
          p_name = partner[0..-7]
        else
          p_name = partner
        end

        if p_bus = Business.find_by(name: p_name)
          bus.partnerships.create(partner: p_bus, acquired: acquired)
          bus.other_partners -= [partner]
          bus.save
        end
      end
    end
  end

  task send_daily_email: :environment do
    User.where(frequency: "daily").map(&:send_email)
  end

  task check_for_inactive_emails: :environment do
    UserMailer.check_bounced_emails
  end
end
