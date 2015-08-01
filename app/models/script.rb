class Script < ActiveRecord::Base
  include CommonFinders
  include Smelter::Scriptable

  runner_include Buzzsaw::DSL

  validates :name,   presence: true
  validates :source, presence: true
end
