json.extract! business, :id, :name, :industries, :employees, :other_partners, :other_competitors, :desired_partnership_types, :offered_partnership_types, :URL, :description, :created_at, :updated_at
json.url business_url(business, format: :json)
