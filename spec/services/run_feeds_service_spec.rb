require 'spec_helper'
require 'sidekiq/testing'

describe RunFeedsService do
  let(:service) { RunFeedsService.new }
  let(:domain)  { create(:domain) }
  let!(:feed)   { create(:feed, domain: domain) }
  let(:page_attributes) { { feed: feed } }

  before(:each) do
    Sidekiq::Testing.disable!
    clear_sidekiq
    feed.domain.clear_redis
  end

  after(:each) do
    clear_sidekiq
    Sidekiq::Testing.fake!
  end

  context "integrations" do
    it "should use DMS" do
      pending "Example"
      expect(true).to eq(false)
    end
  end

  describe "#start_jobs" do
    it "starts a RunFeedWorker job for a feed if there are stale pages in the feed" do
      create(:page, page_attributes.merge(fetched_at: nil))
      feed.domain.clear_redis
      refresh_index

      service.start
      sleep 1
      service.stop
      
      expect(
        RunFeedWorker.jobs.size
      ).to eq(1)
    end

    it "does not start a RunFeedWorker for a feed if the feed has no stale pages" do
      create(:page, page_attributes)
      refresh_index

      service.start
      service.stop

      expect(
        RunFeedWorker.jobs.size
      ).to eq(0)
    end

    it "does not start a RunFeedWorker for a feed if the domain is full" do
      create(:page, page_attributes.merge(fetched_at: nil))
      refresh_index
      domain.max_readers.times { |n| domain.read_with("#{n}") }

      expect(
        RunFeedWorker.jobs.size
      ).to eq(0)
    end
  end
end
