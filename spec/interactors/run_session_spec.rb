require 'spec_helper'
require 'webmock/rspec'

describe RunSession do

  let(:domain)           { "www.retailer.com" }
  let(:session_queue)    { create(:session_queue,    domain: domain) }
  let(:document_queue)   { create(:document_queue,   domain: domain) }
  let(:document_adapter) { create(:document_adapter, domain: domain, document_queue: document_queue) }
  let(:pages)            { 5.times.map { |n| create(:page) } }
  let(:timer)            { Bellbro::Timer.new }
  let(:sessions)         {
    5.times.map do |n|
      build(
        :session,
        session_queue: session_queue,
        adapter_names: [ document_adapter.name ],
        urls:          [ url: pages[n].url.to_s ]
      )
    end
  }

  before :each do
    pages.each do |page|
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

  context "scraping pages" do
    let(:html_page)  { create(:page, url: "http://#{domain}/1.html") }
    let(:xml_page)   { create(:page, url: "http://#{domain}/1.xml") }
    let(:dhtml_page) { create(:page, url: "http://#{domain}/2.html") }
    let(:ssn)        { create(:session, domain: domain, urls: [html_page.url.to_s])}

    it "scrapes an HTML format page" do
      expect_any_instance_of(RunSession).to receive(:get_page).
                                            with(html_page.url.to_s, force_format: :html)
      ssn.page_format = 'html'
      RunSession.call(timer: timer, ssn: ssn, url: html_page.url.to_s)
    end

    it "scrapes an XML format page" do
      expect_any_instance_of(RunSession).to receive(:get_page).
                                            with(xml_page.url.to_s, force_format: :xml)
      ssn.page_format = 'xml'
      RunSession.call(timer: timer, ssn: ssn, url: xml_page.url.to_s)
    end

    it "scrapes an dynamic page" do
      expect_any_instance_of(RunSession).to receive(:render_page).
                                            with(dhtml_page.url.to_s)
      ssn.page_format = 'dhtml'
      RunSession.call(timer: timer, ssn: ssn, url: dhtml_page.url.to_s)
    end
  end

  describe "#call" do
    it "runs a session and extracts JSON objects from catalog pages" do
      pending "Example"
      expect(true).to eq(false)
    end

    it "times out when the timer is up and adds the session back to the queue" do
      pending "Example"
      expect(true).to eq(false)
    end

    it "adds an empty JSON object for a 404 page" do
      pending "Example"
      expect(true).to eq(false)
      #document = document_q.pop
      #expect(document.page.code).to eq(404)
      #expect(document.session.id).to eq("abcd123")
    end
  end
end
