Forem::Forum.class_eval do
  belongs_to :forum_type

  validates :forum_type, presence: true
end

