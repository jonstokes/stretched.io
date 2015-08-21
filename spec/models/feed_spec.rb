require 'rails_helper'

RSpec.describe Feed, type: :model do
  let(:domain)    { "www.retailer.com" }

  context "validations" do
    subject { build(:feed) }

    it { is_expected.to be_valid }

    it "requires name" do
      subject.name = nil
      expect(subject).not_to be_valid
    end

    it "requires page_format" do
      subject.page_format = nil
      expect(subject).not_to be_valid
    end

    it "requires adapter_names" do
      subject.adapter_names = nil
      expect(subject).not_to be_valid
    end

    it "requires domain_name" do
      subject.domain_name = nil
      expect(subject).not_to be_valid
    end

    it "requires urls" do
      subject.urls = nil
      expect(subject).not_to be_valid
    end

    it "requires read_interval" do
      subject.read_interval = nil
      expect(subject).not_to be_valid
    end

    it "requires read_interval to be an integer greater than or equal to 60" do
      subject.read_interval = 59
      expect(subject).not_to be_valid
    end

    it "requires page_format to be one of :html, :xml, :dhtml" do
      subject.page_format = :test
      expect(subject).not_to be_valid
    end
  end

  context "when the feed is destroyed" do
    let(:feed) { create(:feed) }

    before do
      feed.link_pages
      refresh_index
    end

    it "destroys each linked page" do
      feed = Feed.all.first
      expect(feed.pages.count).not_to be_zero
      feed.destroy
      refresh_index
      expect(feed.pages.count).to be_zero
    end

    it "clears the page_queue for that feed" do
      feed.send(:queue_stale_pages)
      expect(feed.page_queue.size).not_to be_zero
      feed.destroy
      expect(feed.page_queue.size).to be_zero
    end
  end

  describe "#stop" do
    let(:feed_id)       { SecureRandom.uuid }
    let(:read_interval) { 3600 }
    let!(:stale_pages)  {
      (4..6).map { |i| create(:page, feed_id: feed_id, fetched_at: nil, url: "http://www.retailer.com/#{i}") } +
        (7..9).map { |i| create(:page, feed_id: feed_id, fetched_at: (read_interval + 100 - i).seconds.ago, url: "http://www.retailer.com/#{i}") }
    }
    let!(:feed)         {
      create(
        :feed,
        id: feed_id,
        read_interval: read_interval,
        urls: stale_pages.map { |p| { url: p.url } }
      )
    }

    before do
      refresh_index
      feed.start
    end

    it "adds a session record to the feed" do
      feed.stop
      refresh_index
      session = Feed.all.to_a.first.sessions.first
      expect(session['duration']).to      be_a(Float)
      expect(session['pages_scraped']).to eq(0)
      expect(session['start_size']).to    eq(6)
      expect(session['started_at']).to    be_a(String)
    end
  end

  describe "#page_queue" do
    let(:read_interval) { 3600 }
    let(:feed_id)       { SecureRandom.uuid }
    let!(:fresh_pages)  {
      (0..3).map { |i| create(:page, feed_id: feed_id, url: "http://www.retailer.com/#{i}") }
    }
    let!(:stale_pages)  {
      (4..6).map { |i| create(:page, feed_id: feed_id, fetched_at: nil, url: "http://www.retailer.com/#{i}") } +
        (7..9).map { |i| create(:page, feed_id: feed_id, fetched_at: (read_interval + 100 - i).seconds.ago, url: "http://www.retailer.com/#{i}") }
    }
    let(:stale_urls)    { stale_pages.sort { |a, b| a.url <=> b.url }.map(&:url) }
    let(:all_pages)     { stale_pages + fresh_pages }
    let!(:feed)         {
      create(
        :feed,
        id: feed_id,
        read_interval: read_interval,
        urls: all_pages.map { |p| { url: p.url } }
      )
    }

    before do
      refresh_index
      feed.start
    end

    it "queues the stale pages in the page queue in order of staleness" do
      expect(feed.page_queue.size).to eq(6)
      fresh_pages.each do |page|
        expect(feed.page_queue.members).not_to include(page.url)
      end
      expect(feed.page_queue.members).to eq(stale_urls)
    end

    it "can be popped" do
      expect(feed.page_queue.pop).to eq(stale_urls.first)
    end
  end

  describe "#expanded_urls" do
    it "can expand an array of url hashes" do
      url_hashes = 5.times.map { |n| { url: "http://#{domain}/#{n}" } } +
        [{
          url: "http://#{domain}/PAGENUM",
          start_at_page: 4,
          stop_at_page: 12
        }]

      feed = create(:feed, urls: url_hashes)
      expect(feed.expanded_urls.size).to eq(13)
      expect(feed.has_url?("http://#{domain}/12")).to eq(true)

      feed.expanded_urls.each do |url|
        expect(URI.parse(url).scheme).to eq("http")
      end
    end
  end
end
