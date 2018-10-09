require 'rubyXL' # Assuming rubygems is already required
require 'faker'
require 'json'
require 'open-uri'

user_url = 'https://randomuser.me/api/'

def def_current_business(row)
  Business.where(name: row.cells[0].value).first
end

start_time = Time.now

puts "Clearing Algolia Index..."
Business.clear_index!
CustomerInterest.clear_index!

puts "Clearing database..."

puts "Unsubscribing users..."
User.all.map(&:unsubscribe)
puts "Destroying notes..."
Note.destroy_all
puts "Destroying users..."
User.destroy_all
puts "Destroying suggestions..."
Suggestion.destroy_all
puts "Destroying clicks..."
Click.destroy_all
puts "Destroying business customer interests..."
BusinessCustomerInterest.destroy_all
puts "Destroying customer interests..."
CustomerInterest.destroy_all
puts "Destroying partneships..."
Partnership.destroy_all
puts "Destroying competitions..."
Competition.destroy_all
puts "Destroying businesses..."
Business.destroy_all

puts "Reading excel file..."
workbook = RubyXL::Parser.parse(ENV['DB_LOCATION'])
worksheet_bus = workbook['Businesses'][1..-1]
worksheet_cli = workbook['Clicks'][1..-1]
worksheet_sug = workbook['Suggestions'][1..-1]

puts "Creating businesses and users..."
worksheet_bus.each do |row|
  des_p_types = row.cells[3].value.nil? ? [] : row.cells[3].value.split("\n").map{ |p_type| Business::PARTNERSHIP_TYPES.invert[p_type] }
  off_p_types = row.cells[4].value.nil? ? [] : row.cells[4].value.split("\n").map{ |p_type| Business::PARTNERSHIP_TYPES.invert[p_type] }
  bus_url = row.cells[9].nil? ? "" : row.cells[9].value
  photo_url = row.cells[10].value.nil? ? "" : row.cells[10].value
  location = row.cells[11].value.nil? ? "" : row.cells[11].value

  user = User.new()

  business_hash = {
    name: row.cells[0].value,
    industries: row.cells[1].value.split("\n"),
    employees: Business.employees.invert[row.cells[2].value],
    desired_partnership_types: des_p_types,
    offered_partnership_types: off_p_types,
    url: bus_url
  }

  user_serialized = open(user_url).read
  user_hash = JSON.parse(user_serialized)["results"][0]

  business = Business.create!(business_hash)
  unless bus_url.empty?
    domain = business.url.match(/[http[s]?:\/\/]?(?:www\.)?([\w\-]*(?:\.[a-z\.]+))/i)[-1]
  end

  puts business_hash[:name]

  first_name = Faker::Name.first_name
  email = if domain.nil?
     "#{first_name}@#{business_hash[:name].gsub(/[\W\d]+/, "")}.com"
  else
    "#{first_name}@#{domain}"
  end

  user = {
    first_name: first_name,
    last_name: user_hash["name"]["last"],
    email: email,
    password: "password",
    password_confirmation: "password",
    business_id: business.id,
    linkedin_url: 'https://www.linkedin.com/in/kate-baskin-943a15a1/',
    location: location,
    frequency: ["daily", "weekly", "monthly"].sample,
    confirmed_at: Time.now.utc
  }

  user = User.create!(user)
  user.remote_avatar_url = user_hash["picture"]["thumbnail"]
  user.save!

  business.add_domain
  # p photo_url
  business.remote_photo_url = photo_url
  business.save!
end


puts "Adding competitors..."
worksheet_bus.each do |row|
  current_business = def_current_business(row)
  competitors = row.cells[5].value.nil? ? [] : row.cells[5].value.split("\n")

  competitors.each do |competitor|
    if Business.where(name: competitor).first
      current_business.competitions.create!(competitor: Business.where(name: competitor).first)
    else
      current_business.other_competitors << competitor
      current_business.save!
    end
  end
end

puts "Adding partnerships..."
worksheet_bus.each do |row|
  current_business = def_current_business(row)

  desired_partnerships = row.cells[6].value.nil? ? [] : row.cells[6].value.split("\n")
  acquired_partnerships = row.cells[7].value.nil? ? [] : row.cells[7].value.split("\n")

  desired_partnerships.each do |des|
    if Business.where(name: des).first
      current_business.partnerships.desired.create!(partner: Business.where(name: des).first)
    else
      current_business.other_partners << des
      current_business.save!
    end
  end

  acquired_partnerships.each do |acq|
    if Business.where(name: acq).first
      current_business.partnerships.acquired.create!(partner: Business.where(name: acq).first)
    else
      current_business.other_partners << acq
      current_business.save!
    end
  end
end

puts "Adding customer interests..."
worksheet_bus.each do |row|
  current_business = def_current_business(row)
  interests = row.cells[8].value.split("\n")

  interests.each do |interest|
    current_business.business_customer_interests.create!(
      customer_interest: CustomerInterest.where(name: interest).first_or_create
    )
  end
end

puts "Adding clicks..."
worksheet_cli.each do |row|
  click_hash = {
    clicker: def_current_business(row),
    clicked: Business.where(name: row.cells[1].value).first,
    count: row.cells[2].value
  }
  # p click_hash
  Click.create!(click_hash)
end

puts "Adding suggestions..."
Business.all.each do |business|
  # business.update_suggestions!
  business.create_suggestions
end

# puts "Creating Demo Cases"
# tinder = Business.find_by_name('Tinder')
# ford = Business.find_by_name('Ford')
# nudie = Business.find_by_name('Nudie')

# tinder.clicks.find_by_clicked_id(ford.id).update!(count: 10)
# ford.clicks.find_by_clicked_id(tinder.id).update!(count: 10)

# nudie.users.first.destroy

# nudie_user = {
#   first_name: 'Kate',
#   last_name: 'Baskin',
#   email: 'kate.baskin@nudie.com',
#   password: "password",
#   password_confirmation: "password",
#   business_id: nudie.id,
#   linkedin_url: 'https://www.linkedin.com/in/kate-baskin-943a15a1/',
#   location: 'Australia'
# }

# kate = User.create!(nudie_user)

# kate.remote_avatar_url = 'https://media.licdn.com/dms/image/C5603AQEt24SkG3jiLw/profile-displayphoto-shrink_800_800/0?e=1529373600&v=beta&t=17xjY0wVM9WRtHilpncSPzQTYnD6AeWd46WvkezuJ2s'
# kate.save!
# nudie.users << kate
# nudie.youtube_url = 'https://www.youtube.com/watch?v=Zum4X77SXcM'
# nudie.save!

time_taken = ((Time.now - start_time) / 60).round(2)

mins = time_taken.floor
secs = (time_taken % 1 * 60).floor

puts "Done! Time taken: #{mins} min #{secs} sec"
