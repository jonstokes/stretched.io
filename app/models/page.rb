class Page < ActiveRecord::Base
  belongs_to :session
  has_many :documents
end
