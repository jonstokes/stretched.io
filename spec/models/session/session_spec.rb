require 'rails_helper'

RSpec.describe Session, type: :model do
  context "validations" do
    subject { create(:session) }

    it { is_expected.to be_valid }

    %w(session_queue_id page_format document_adapters).each do |attr|
      it "requires #{attr}" do
        subject.send("#{attr}=", nil)
        expect(subject).not_to be_valid
      end
    end

    it "requires page_format to be one of :html, :xml, :dhtml" do
      subject.page_format = :test
      expect(subject).not_to be_valid
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
