require 'rails_helper'

RSpec.describe Session, type: :model do
  context "validations" do
    subject { build(:session) }

    it { is_expected.to be_valid }

    it "requires page_format" do
      subject.page_format = nil
      expect(subject).not_to be_valid
    end

    it "requires adapter_names" do
      subject.adapter_names = nil
      expect(subject).not_to be_valid
    end

    it "requires page_format to be one of :html, :xml, :dhtml" do
      subject.page_format = :test
      expect(subject).not_to be_valid
    end
  end

  context "hooks" do
    subject { create(:session) }

    it "creates a Session::Reader for each adapter" do
      expect(Session::Reader.where(session_id: subject.id)).not_to be_empty
      expect(subject.document_adapters).not_to be_empty
    end
  end

  describe "#queue" do
    it "returns a handle to the session queue even after the session has been popped" do
      session = create(:session)
      session.update(session_queue: nil)
      expect(session.queue).to be_a(Session::Queue)
    end
  end

  describe "#urls" do
    let(:domain)    { "www.retailer.com" }

    it "can take in an expanded array of url strings" do
      urls = 5.times.map { |n| "http://#{domain}/#{n}" }
      create(:session, urls: urls)

      session = Session::Session.first
      expect(session.urls).to eq(urls)
    end

    it "can expand an array of url hashes" do
      url_hashes = 5.times.map { |n| { url: "http://#{domain}/#{n}" } } +
        [{
          url: "http://#{domain}/PAGENUM",
          start_at_page: 4,
          stop_at_page: 12
        }]

      session = create(:session, urls: url_hashes)
      expect(session.urls.size).to eq(13)
      expect(session.has_url?("http://#{domain}/12")).to eq(true)

      session.urls.each do |url|
        expect(URI.parse(url).scheme).to eq("http")
      end
    end
  end
end
