class Crewmanship < ActiveRecord::Base
  # status(trial_active,trial_expired,trial_canceled,active,canceled,completed)
  belongs_to :mission
  belongs_to :user

  after_create :set_expires_at

  private
  def set_expires_at
    update_attribute(:trial_expires_at, 30.days.from_now)
  end
end
