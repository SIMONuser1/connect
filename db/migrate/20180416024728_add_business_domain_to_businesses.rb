class AddBusinessDomainToBusinesses < ActiveRecord::Migration[5.1]
  def change
    add_column :businesses, :business_domain, :string
  end
end
