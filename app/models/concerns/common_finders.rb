module CommonFinders
  extend ActiveSupport::Concern

  def self.find_by_name(name)
    db { self.find_by(name: name) }
  end

  private
  
  def db(&b); self.class.db(&b); end

  class_methods do
    def db(&b); ActiveRecord::Base.connection_pool.with_connection(&b); end
  end
end
