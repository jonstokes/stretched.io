class Extension < ActiveRecord::Base
  include CommonFinders
  include Smelter::Extendable
  
  validates :name,   presence: true
  validates :source, presence: true

  def self.all_names
    db { self.pluck(:name) }
  end
end
