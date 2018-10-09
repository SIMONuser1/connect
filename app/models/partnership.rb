class Partnership < ApplicationRecord
  belongs_to :business
  belongs_to :partner, class_name: 'Business', foreign_key: :partner_id
end
