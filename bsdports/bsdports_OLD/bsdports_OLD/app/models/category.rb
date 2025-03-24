class Category < ApplicationRecord
  belongs_to :platform

  has_many :ports, dependent: :destroy

  extend FriendlyId
  friendly_id :name
end

