class Click < ApplicationRecord
  belongs_to :clicker, class_name: 'Business', foreign_key: :clicker_id
  belongs_to :clicked, class_name: 'Business', foreign_key: :clicked_id
end
