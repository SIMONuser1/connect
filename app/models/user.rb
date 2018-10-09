class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_one :business
  has_many :notes, foreign_key: :author_id
  has_many :user_suggestions, dependent: :destroy
  has_many :suggestions, through: :user_suggestions

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable
  belongs_to :business, required: false

  mount_uploader :avatar, AvatarUploader

  after_create :subscribe_user
  after_update :update_subscription

  MAILCHIMP_SUBGROUP_IDS = {
    "daily" => ENV['MAILCHIMP_DAILY_ID'],
    "weekly" => ENV['MAILCHIMP_WEEKLY_ID'],
    "monthly" => ENV['MAILCHIMP_MONTHLY_ID']
  }

  def full_name
    "#{first_name.capitalize} #{last_name.capitalize}"
  end

  def unconfirm
    frequency = "never"
    confirmation_token = nil
    confirmed_at = nil
    save
  end

  def send_email
    if frequency == "daily"
      UserMailer.with(user: self).daily_suggestions.deliver_now
    elsif frequency == "weekly"
      UserMailer.with(user: self).weekly_suggestions.deliver_now
    elsif frequency == "monthly"
      UserMailer.with(user: self).monthly_suggestions.deliver_now
    else # frequency == "never"
      return
    end
  end

  # MailChimp user subscription functions
  def gibbon_init
    Gibbon::Request.new(api_key: ENV['MAILCHIMP_API_KEY'])
  end

  def mailchimp_frequency_hash
    frequencies = {
      "#{ENV['MAILCHIMP_DAILY_ID']}" => false,
      "#{ENV['MAILCHIMP_WEEKLY_ID']}" => false,
      "#{ENV['MAILCHIMP_MONTHLY_ID']}" => false
    }

    frequencies["#{MAILCHIMP_SUBGROUP_IDS[frequency]}"] = true

    frequencies
  end

  def subscribe_user
    gibbon = gibbon_init
    md5_email = Digest::MD5.hexdigest(email.downcase)

    gibbon.lists(ENV['MAILCHIMP_LIST_ID']).members(md5_email).upsert(
      body: {
        email_address: email,
        status: "subscribed",
        interests: mailchimp_frequency_hash,
        merge_fields: {
          FNAME: first_name,
          LNAME: last_name
        }
      }
    )
  end

  def update_subscription
    frequency == "never" ? unsubscribe : subscribe_user
  end

  def unsubscribe
    gibbon = gibbon_init
    md5_email = Digest::MD5.hexdigest(email.downcase)

    gibbon.lists(ENV['MAILCHIMP_LIST_ID']).members(md5_email).update(body: { status: "unsubscribed" })
  end
  # End of MailChimp functions

  def location_filtered_suggestions
    if location.nil?
      business.suggestions.order(:rating)
    else
      business.suggestions.all.inject([]) do |mem, sug|
        mem << sug if sug.suggested_business.locations.include?(location)
        mem
      end
    end
  end

  def last_ten_suggestions
    # raise
    filtered_suggestions = location_filtered_suggestions
    # raise
    last_ten = user_suggestions.order(created_at: :desc)[0..9].map(&:suggestion)
    counter = 0
    # raise
    while last_ten.count < 10
      # Fill up the list with unqiue high rating entries
      last_ten = last_ten | [filtered_suggestions[counter]]
      counter += 1
    end

    last_ten
  end

  def remove_previous_suggestions(list)
    list - self.suggestions
  end

  def get_daily_suggestion
    filtered_suggestions = remove_previous_suggestions(location_filtered_suggestions)
    return if filtered_suggestions.nil? || filtered_suggestions.empty?

    day = Date.today.strftime("%A")
    # testing
    days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    day = days.sample

    if day == 'Monday'
      # Return a below average match
      bad_list = filtered_suggestions.select{ |s| s.text_rating == 'Below Average Match' }
      attempt = bad_list.empty? ? filtered_suggestions.sample : bad_list.sample

    elsif ['Tuesday', 'Wednesday', 'Thursday'].include?(day)
      # Return as good a match as possible
      attempt = filtered_suggestions.first

    elsif day == 'Friday'
      # Return a suggestion for a business matched well with you
      attempts = Suggestion.where(suggested_business: business)
        .inject([]) do |mem, sug|
          if sug.business.locations.include?(location)
            mem << Suggestion.find_by(business: business, suggested_business: sug.business)
          end
          mem
        end

      # nested while loop so that attempts is only calculated once
      attempts = remove_previous_suggestions(attempts)
      return if attempts.empty?
      attempt = attempts.first
    else
      return
    end

    self.user_suggestions.create!(suggestion: attempt, day: day)

    # Only store 20 results
    user_suggestions.order(created_at: :desc)[20..-1].map(&:destroy) if user_suggestions.count > 20

    self.save!
  end
end
