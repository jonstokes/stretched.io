require 'rails_helper'

RSpec.describe Page, type: :model do

  before(:each) { refresh_index }

  context "validations" do
    subject { create(:page) }

    it { is_expected.to be_valid }

    it "requires feed_id" do
      subject.feed_id = nil
      expect(subject).not_to be_valid
    end

    it "requires url" do
      subject.url = nil
      expect(subject).not_to be_valid
    end

    it "requires url to be a URI" do
      subject.url = "foobar.com"
      expect(subject).not_to be_valid
    end
  end

  context "attributes and hooks" do
    subject { create(:page) }

    it "has attributes of the correct types" do
      expect(subject.fetched_at).to be_a(Time)
    end
  end

  describe "#before_destroy" do
    subject { create(:page, fetched_at: nil) }

    it "deletes its url from the domain's page_queue" do
      feed = Feed.find(subject.feed_id)
      refresh_index
      feed.send(:queue_stale_pages)
      expect(feed.page_queue.size).not_to be_zero
      subject.destroy
      expect(feed.page_queue.size).to be_zero
    end
  end

  describe "#update_from_source" do
    it "copies values from the source page into the page" do
      source = create(
        :sunbro_page,
        body: "<html><head></head><body>Invalid Listing!</body></html>"
      )
      page = create(:page, url: source.url)
      page.update_from_source(source)
      expect(page.code).to eq(source.code)
      expect(page.body).to eq(source.body)
      expect(page.visits).to eq(1)
    end
  end

  describe "#to_hash" do
    it "does not include certain keys" do
      source = create(
        :sunbro_page,
        body: "<html><head></head><body>Invalid Listing!</body></html>"
      )
      page = create(:page, url: source.url)
      page.update_from_source(source)
      expect(page.to_hash.keys).not_to include(:visited, :body, :doc)

      page.save
      refresh_index
      page = Page.all.first

      expect(page.fetched_at).not_to be_nil
      expect(page.doc).to be_nil
      expect(page.body).to be_nil
      expect(page.visited).to be_nil
    end
  end

  describe "::new" do
    it "sets the object's ID to the url sans scheme" do
      page = create(:page)
      expect(page.id).to eq(Page.url_to_id(page.url))
    end
  end
end
