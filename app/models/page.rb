class Page < ActiveRecord::Base
  belongs_to :session,   class_name: "Session::Session"
  has_many   :documents, class_name: "Document::Document"

  validates :url,           presence: true
  validate :url,            :valid_url_format
  validates :code,          presence: true, numericality: { greater_than: 99, less_than: 506 }
  validates :headers,       presence: true
  validates :response_time, presence: true, numericality: { greater_than: 0 }

  private

  def valid_url_format
    return if !!URI.parse(url).scheme
    errors.add(:url, "Invalid url")
  rescue URI::InvalidURIError => e
    errors.add(:url, e.message )
  end
end
