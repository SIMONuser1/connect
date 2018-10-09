class BusinessCustomerInterest < ApplicationRecord
  belongs_to :business
  belongs_to :customer_interest

end
