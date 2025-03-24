class Port < ApplicationRecord
  belongs_to :platform
  belongs_to :category

  extend FriendlyId
  friendly_id :name
end

