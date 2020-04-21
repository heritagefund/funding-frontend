class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :confirmable

  belongs_to :organisation, optional: true

  has_many :projects

  attr_accessor :validate_details
  attr_accessor :validate_address

  # These attributes are used to set individual error messages
  # for each of the project date input fields
  attr_accessor :dob_day
  attr_accessor :dob_month
  attr_accessor :dob_year

  validates :name, presence: true, if: :validate_details?
  validates :dob_day, presence: true, if: :validate_details?
  validates :dob_month, presence: true, if: :validate_details?
  validates :dob_year, presence: true, if: :validate_details?
  validates :line1, presence: true, if: :validate_address?
  validates :townCity, presence: true, if: :validate_address?
  validates :county, presence: true, if: :validate_address?
  validates :postcode, presence: true, if: :validate_address?

  validate :date_of_birth_is_date_and_in_past?, if: :validate_details?

  # Override the send_devise_notification method to allow for
  # non-blocking sending using ActiveJob
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def validate_details?
    validate_details == true
  end

  def validate_address?
    validate_address == true
  end

  def date_of_birth_is_date_and_in_past?
    unless Date.valid_date?(self.dob_year.to_i, self.dob_month.to_i, self.dob_day.to_i)
      errors.add(:date_of_birth, 'Date of birth must be a valid date')
    else
      unless Date.new(self.dob_year.to_i, self.dob_month.to_i, self.dob_day.to_i).past?
        errors.add(:date_of_birth, 'Date of birth must be in the past')
      end
    end
  end

    def self.current_user(user_id)
        @user = User.find_by(uid: user_id)
    end
end
