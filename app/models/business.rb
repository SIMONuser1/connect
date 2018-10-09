class Business < ApplicationRecord
  require 'open-uri'
  require 'nokogiri'

  has_many :users
  has_many :partnerships, dependent: :destroy
  has_many :partners, through: :partnerships
  has_many :competitions, dependent: :destroy
  has_many :competitors, through: :competitions
  has_many :suggestions, dependent: :destroy
  has_many :suggested_businesses, through: :suggestions
  has_many :clicks, foreign_key: :clicker_id, dependent: :destroy
  has_many :businesses_clicked, through: :clicks, source: :clicked
  has_many :business_customer_interests, dependent: :destroy
  has_many :customer_interests, through: :business_customer_interests
  has_many :notes, foreign_key: :owner_id, dependent: :destroy

  alias_attribute :file, :photo

  mount_uploader :photo, PhotoUploader

  after_create :add_description

  include AlgoliaSearch

  algoliasearch per_environment: true do
    attribute :name, :industries, :customer_interests
    attributesForFaceting [:customer_interests]
    searchableAttributes ['name']
    attributeForDistinct "name"

  end

  enum employees: {
    :"1_to_10" => "1 to 10",
    :"11_to_50" => "11 to 50",
    :"51_to_100" => "51 to 100",
    :"101_to_500" => "101 to 500",
    :"501_to_1000" => "501 to 1000",
    :"1001_to_5000" => "1001 to 5000",
    :"5000+" => "5000+",
  }

  PARTNERSHIP_TYPES = {
    ev_p: 'Event Partnerships',
    pr_p: 'PR',
    cpo_p: 'Cross Promotion Opportunities',
    tech_p: 'Technical Partnerships',
    eco_p:'Ecosystem Partnerships'
  }

  def match_percent_with(business)
    suggestions.where(suggested_business_id: business.id).first.rating
  end

  def match_rating_with(business)
    suggestions.where(suggested_business_id: business.id).first.text_rating
  end

  def who_clicked_who(business)
    click_array = click_counts(business)

    if click_array.sum.zero?
      "No clicks"
    elsif click_array[0].zero?
      "They clicked"
    elsif click_array[1].zero?
      "You clicked"
    else
      "Both clicked"
    end
  end

  def locations
    users.map(&:location)
  end

  def who_matched_with_me
    Suggestion.where(suggested_business_id: id).first(10)
    #will be an array of Users
  end

  def remove_self_from_list(list)
    return list.nil? ? [] : list - [self]
  end

  def business_notes(business)
    notes.where(noted_id: business.id)
  end

  def mutual_clicks(business)
    click_counts(business).min
  end

  def companies_competitors_clicked
    unless self.competitors.first.nil?
      competitors.sample.clicks.limit(6).map do |click|
        Business.find(click.clicked_id)
      end
    end
  end

  def photo_url(business)
    suggestions.photo
  end

  def p_types_desired_match(business)
    (desired_partnership_types & business.offered_partnership_types).map{ |e| PARTNERSHIP_TYPES[e.to_sym]}
  end

  def customer_skills_match(business)
    (customer_interests & business.customer_interests).map{ |e| e.name}
  end

  def industries_match(business)
    industries & business.industries
  end

  def create_suggestions(weights = nil)
    Business.where.not(id: id).each do |bus|
      self.suggestions.where(suggested_business: bus).first_or_create
    end
  end

  def update_suggestions!(weights = nil)
    create_suggestions
    suggestions.map(&:update_rating)
    # suggested_businesses
  end

  def add_description
    begin
      html_file = open(url).read unless url.nil?
    rescue
      return
    end
    html_doc = Nokogiri::HTML(html_file)

    if site_desc = html_doc.search("meta[name='description']").map{|n|n['content']}.first
      self.description = site_desc.strip
    end
    save
  end

  def add_domain
    if self.business_domain.nil? && users.first
      domain = users.first.email.match(/(?<=@).+/)[0]
     # domain = url.match(/[http[s]?:\/\/]?(?:www\.)?([\w\-]*(?:\.[a-z\.]+))/i)[-1]
      self.business_domain = domain # unless domain.nil?
      save
    end
  end

  def youtube_regex
    youtube_url.match(/\=(.*)/)[1]
  end

  def also_clicked
    ind_list = remove_self_from_list(Business.where("industries && ARRAY[?]::varchar[]", industries))

    cust_list = remove_self_from_list(BusinessCustomerInterest.where(customer_interest_id: self.business_customer_interest_ids)
      .map(&:business)
      )

    # raise
    if ind_list.empty? && cust_list.empty?
      Business.where.not(id: self.id).sample(4)
    elsif ind_list.empty?
      cust_list.sample(4)
    else
      ind_list.sample(4)
    end
  end

  private

  def click_counts(business)
    you_clicked_them = clicks.where(clicked_id: business.id).first.count
    they_clicked_you = business.clicks.where(clicked_id: id).first.count

    [you_clicked_them, they_clicked_you]
  end
end
