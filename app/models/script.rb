class Script < ActiveRecord::Base
  validates :name, presence: true
  validates :source, presence: true

end
