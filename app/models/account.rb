class Account < ActiveRecord::Base
  has_many :memberships
  has_many :users, :through => :memberships
  has_many :courses
  has_many :roles, through: :courses
  has_many :suggestions
  has_many :missions

  validates :name, :subdomain, :presence => true
  validates_uniqueness_of :subdomain

  before_validation :format_subdomain, :on => :create

  scope :open, where(:private => false)
  scope :private, where(:private => true)

  has_attached_file :photo, :styles => { :small => "243x48#", :banner => "959x349#" },
                    :storage => :s3,
                    :s3_credentials => S3_CREDENTIALS,
                    :path => "account/:style/:id/:filename"

  validates_attachment_size :photo, :less_than => 5.megabytes
  validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/png']

  has_attached_file :logo, :styles => { :small => "200x76>" },
                    :storage => :s3,
                    :s3_credentials => S3_CREDENTIALS,
                    :path => "account/:style/:id/:filename"

  validates_attachment_size :logo, :less_than => 5.megabytes
  validates_attachment_content_type :logo, :content_type => ['image/jpeg', 'image/png']

  def self.public_ids
    self.open.collect(&:id) + [0] - [1] - [2] - [3]
  end

  def admins
    admins = self.memberships.where(:admin => true)
    if admins.any?
      admins.collect(&:user)
    else
      []
    end
  end

  private
  def format_subdomain
    self.subdomain = self.subdomain.parameterize
  end

  def valid_email?(email)
    email.match(/#{email_regex}/) ? true : false
  end

  def invalid_email?(email)
    !valid_email?(email)
  end

  def valid_user?(user)
    return true if email_regex.blank?
    email = user.try(:email) || ""
    valid_email?(email)
  end

  def invalid_user?(user)
    !valid_user?(user)
  end
end
