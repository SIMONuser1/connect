class Competition < ApplicationRecord
  belongs_to :business
  belongs_to :competitor, class_name: 'Business', foreign_key: :competitor_id
end
