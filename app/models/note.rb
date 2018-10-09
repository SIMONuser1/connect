class Note < ApplicationRecord
  belongs_to :owner, class_name: 'Business', foreign_key: :owner_id
  belongs_to :noted, class_name: 'Business', foreign_key: :noted_id
  belongs_to :author, class_name: 'User', foreign_key: :author_id
end
