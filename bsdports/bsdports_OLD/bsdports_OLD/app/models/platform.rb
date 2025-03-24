class Platform < ApplicationRecord
  has_many :categories, dependent: :destroy

  extend FriendlyId
  friendly_id :name
end

