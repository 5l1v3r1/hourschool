class Esuggestion < ActiveRecord::Base
  belongs_to :enterprise
  validates_presence_of :name, :description, :requested_by
  attr_accessible :name, :description, :requested_by
  acts_as_voteable
end
