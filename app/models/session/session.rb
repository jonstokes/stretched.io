module Session
  class Session < ActiveRecord::Base
    include CommonFinders

    before_save do
      self[:urls] = urls
    end

    belongs_to :session_queue, class_name: "Session::Queue"
    has_many   :pages,         dependent: :destroy

    validates :session_queue_id,  presence: true
    validates :page_format,       presence: true, inclusion: { in: %w(html xml dhtml) }
    validates :document_adapters, presence: true

    def pop_url
      urls.shift
    end

    def urls
      @expanded_urls ||= self[:urls].present? ? expand_urls : []
    end

    def has_url?(url)
      urls.include?(url)
    end

    private

    def expand_urls
      self[:urls].map do |feed|
        if feed.is_a?(Hash)
          expand_links(feed)
        else
          feed
        end
      end.flatten.uniq
    end

    def expand_links(feed)
      feed.symbolize_keys!
      return feed[:url] unless feed[:start_at_page]
      (feed[:start_at_page]..feed[:stop_at_page]).step(feed[:step] || 1).map do |page_number|
        feed[:url].sub("PAGENUM", page_number.to_s)
      end
    end

  end
end
