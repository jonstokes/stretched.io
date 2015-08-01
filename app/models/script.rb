class Script < ActiveRecord::Base
  include CommonFinders

  validates :name, presence: true
  validates :source, presence: true
end
