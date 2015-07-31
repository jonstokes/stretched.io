require 'spec_helper'
require 'webmock/rspec'
require 'sidekiq/testing'

WebMock.disable_net_connect!(allow_localhost: true)

describe RunSessionsWorker do
  let(:worker)           { RunSessionsWorker.new }
  let(:domain)           { "www.retailer.com" }
  let(:session_queue)    { create(:session_queue,    domain: domain) }
  let(:document_queue)   { create(:document_queue,   domain: domain) }
  let(:document_adapter) { create(:document_adapter, domain: domain, document_queue: document_queue) }
  let(:web_pages)        { 5.times.map { |n| create(:sunbro_page) } }

  let(:sessions)       {
    5.times.map do |n|
      build(
        :session,
        session_queue:     session_queue,
        document_adapters: [ document_adapter.name ],
        urls:              [ url: web_pages[n].url.to_s ]
      )
    end
  }

  before :each do
    web_pages.each do |page|
      stub_request(:get, page.url.to_s).
        to_return {
          {
            body:    page.body,
            status:  page.code,
            headers: page.headers
          }
        }
    end

    session_queue.add(sessions)
  end

  describe "#perform" do
    it "empties the session_queue, extracts JSON documents from the pages, and adds the documents to the document_queue" do
      worker.perform(queue: domain)

      expect(session_queue.is_being_read?).to    eq(false)
      expect(session_queue.size).to              eq(0)
      expect(document_queue.size).to             eq(5)
      while document = document_queue.pop
        expect(document).to                       be_a?(Document)
        expect(document.document_adapter.name).to eq(document_adapter.name)
        expect(document.page.url).to              include(domain)
        expect(document.title).to                 include("Page title")
      end
    end

    it "times out and adds the session with the remaining urls back to the session queue" do
      worker.perform(queue: domain, timeout: 1)
      expect(session_queue.size).to eq(3)
      expect(document_queue.size).to eq(1)
      while document = document_queue.pop
        expect(document).to                       be_a?(Document)
        expect(document.document_adapter.name).to eq(document_adapter.name)
        expect(document.page.url).to              include(domain)
        expect(document.title).to                 include("Page title")
      end
    end
  end
end
