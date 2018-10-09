class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  scope :acquired, -> { where(acquired: true) }
  scope :desired, -> { where(acquired: false) }
end
