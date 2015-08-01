class Extension < ActiveRecord::Base
  validates :name, presence: true
  validates :source, presence: true

  def self.all_names
    self.pluck(:name)
  end
end
