class Session
  include Virtus.model

  # Recorded stats
  attribute :jid,                String, mapping: { index: 'not_analyzed' }
  attribute :next_jid,           String, mapping: { index: 'not_analyzed' }
  attribute :started_at,         DateTime
  attribute :duration,           Float
  attribute :start_size,         Integer
  attribute :pages_scraped,      Integer
  attribute :timed_out,          Boolean

  # Derived stats
  attribute :mean_response,      Integer #ms
  attribute :median_response,    Integer #ms
  attribute :mean_scrape,        Integer #ms
  attribute :median_scrape,      Integer #ms
  attribute :mean_parse,         Integer #ms
  attribute :median_parse,       Integer #ms
  attribute :eff_rate,           Integer #ms per page

  # Sources
  attribute :response_times,     Array
  attribute :parse_times,        Array
  attribute :scrape_times,       Array

  def run_stats(page)
    @scrape_times   ||= []
    @response_times ||= []
    @parse_times    ||=[]

    @scrape_times   << page.scrape_time        if page.scrape_time.present?
    @response_times << page.response_time      if page.response_time.present?
    @parse_times    += page.parse_times.values if page.parse_times.present?

    @scrape_times.extend(DescriptiveStatistics)
    @response_times.extend(DescriptiveStatistics)
    @parse_times.extend(DescriptiveStatistics)

    @mean_response   = response_times.mean
    @median_response = response_times.median
    @mean_scrape     = scrape_times.mean
    @median_scrape   = scrape_times.median
    @mean_parse      = parse_times.mean
    @median_parse    = parse_times.median
    @eff_rate        = pages_scraped.to_f / (duration * 1000).to_f
  end

  def to_hash
    super.except(:response_times, :scrape_times, :parse_times)
  end
end
