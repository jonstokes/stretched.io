module Session
  class Session < ActiveRecord::Base
    include CommonFinders

    class Stats < Struct.new(:parse_times, :response_times)
      # user descriptive-stats gem to generate stats here
    end

    before_save do
      self[:urls] = urls
    end

    after_create do
      # Join models must be created manually because they include
      # a ref to session_queue. This is done so that after a session
      # is popped from a queue, it still has a handle to that queue.
      @adapters.each do |a|
        db do
          self.session_readers.create(
            document_adapter: a,
            session_queue: session_queue
          )
        end
      end
    end

    belongs_to :session_queue,     class_name: "Session::Queue"
    has_many   :session_readers,   class_name: "Session::Reader"
    has_many   :document_adapters, class_name: "Document::Adapter", through: :session_readers

    validates :page_format,       presence: true, inclusion: { in: %w(html xml dhtml) }
    validates :adapter_names,     presence: true
    validate  :adapter_names,     :load_adapters

    delegate :with_limit, to: :session_queue

    attr_writer :adapter_names

    def adapter_names
      return db { document_adapters.pluck(:name) } if persisted?
      @adapter_names
    end

    def pop_url
      urls.shift
    end

    def urls
      @expanded_urls ||= self[:urls].present? ? expand_urls : []
    end

    def size
      urls.size
    end

    def has_url?(url)
      urls.include?(url)
    end

    def queue
      session_queue || session_readers.first.session_queue
    end

    def start!
      @start_size = size
      @started_at = Time.now.utc
    end

    def stop!
      # FIXME: Must call this when session is done, and needs spec
      @end_size ||= size
      @stopped_at = Time.now.utc
    end

    def stopped?
      !!@started_at && !!@stopped_at
    end

    private

    def load_adapters
      return errors.add(:adapter_name, "Can't be empty") unless adapter_names.present?
      @adapters = adapter_names.map do |name|
        Document::Adapter.find_by_name(name)
      end
    rescue ActiveRecord::RecordNotFound => e
      errors.add(:adapter_name, message: e.message)
    end

    def validate_session_readers
      errors.add("At least one document adapter is required") if document_adapters.empty?
    end

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
