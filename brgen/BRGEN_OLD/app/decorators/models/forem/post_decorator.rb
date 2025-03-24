Forem::Post.class_eval do
  acts_as_nested_set parent_column: "reply_to_id"

  has_many :flags, as: :flaggable
  has_many :photos
  has_many :likes

  belongs_to :user

  attr_accessor :password

  accepts_nested_attributes_for :photos

  validates :email, presence: true, if: Proc.new { topic && !topic.try(:new_record?) && email_or_comment_disabled? }

  before_create :encrypt_password

  after_initialize :generate_random_password, :generate_post_number
  after_create :subscribe_replier, unless: Proc.new { email.blank? }
  after_create :skip_pending_review

  def photos?
    !photos.empty?
  end

protected
  def skip_pending_review
    approve!
  end

  def email_or_comment_disabled?
    email.blank? && (reply_type == "email" || !topic.enable_comments)
  end

  def email_topic_subscribers
    # return if topic.ad? && reply_type == "email"
    #
    # topic.public_posts.each do |subscriber|
    #   if subscriber.id != id && !subscriber.email.blank?
    #     Forem::SubscriptionMailer.topic_reply(id, subscriber.id).deliver
    #   end
    # end
    # update_attribute(:notified, true)
  end

  def generate_post_number
    self.number = SecureRandom.hex
  end

  def encrypt_password
    self.password_salt = BCrypt::Engine.generate_salt
    self.password_hash = BCrypt::Engine.hash_secret(self.password, self.password_salt)
  end

  def generate_random_password
    self.password = SecureRandom.hex(5)
  end
end

