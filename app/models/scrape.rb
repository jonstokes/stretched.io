class Scrape
  include Virtus.model
  include ActiveModel::Model
  include Sunbro

  attribute :url,         String
  attribute :page_format, String
  attribute :page,        Sunbro::Page
  attribute :xpath,       String
  attribute :mapping,     String
  attribute :property_setters, String
  attribute :script_names, Array[String]
  attribute :schema_name, String

  validates :url,         presence: true
  validates :page_format, presence: true
  validates :xpath,       presence: true
  validates :mapping,     presence: true
  validates :property_setters, presence: true

  def results
    ExtractDocumentsFromPage.call(
      adapters: [adapter],
      page: page
    )
  end

  def page
    p = ::Page.new
    p.update_from_source(source)
    p
  end

  def adapter
    Extension.register_all
    Adapter.new(
      xpath:            xpath,
      property_setters: YAML.load(property_setters),
      mapping:          mapping,
      schema_name:      schema_name,
      script_names:     script_names
    )
  end

  def source
    @source || fetch!
  end

  def fetch!
    @source = conn.fetch_page(
      url,
      force_format: page_format.to_s.downcase,
      tries:        2,
      sleep:        0.5
    )
  end

  def conn
    @conn ||= Sunbro::Connection.new
  end
end