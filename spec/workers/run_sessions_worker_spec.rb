require 'spec_helper'
require 'webmock/rspec'
require 'sidekiq/testing'

WebMock.disable_net_connect!(allow_localhost: true)

describe RunSessionsWorker do
  let(:document_adapter) { create(:document_adapter) }

  let(:worker)         { RunSessionsWorker.new }
  let(:domain)         { "www.retailer.com" }
  let(:page_source)    { File.open(Rails.root.join("spec","fixtures","html","product_page.html")) { |f| f.read } }
  let(:session_queue)  { create(:session_queue,  name: domain) }
  let(:document_queue) { create(:document_queue, name: domain) }
  let(:sessions)       { YAML.load_file(Rails.root.join('spec','fixtures','sessions.yml')) }

  before :each do
    session_queue.add(sessions)

    stub_request(:get, domain).
      to_return(
        body:    page_source,
        status:  200,
        headers: { 'Content-Length' => 100 }
      )
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
