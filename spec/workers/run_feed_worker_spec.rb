require 'spec_helper'
require 'webmock/rspec'
require 'sidekiq/testing'

WebMock.disable_net_connect!(allow_localhost: true)

describe RunFeedWorker do
  let(:worker)  { RunFeedWorker.new }
  let(:feed)    { create(:feed, :with_pages) }

  before(:each) do
    feed.pages.each { |page| page.update(fetched_at: nil) }
    feed.domain.clear_redis
    refresh_index
  end

  context "should_run?" do
    it "runs if the feed has stale pages and the domain isn't oversubscribed" do
      expect(RunSession).to receive(:call)
      worker.perform(feed_id: feed.id)
    end

    it "does not run if the feed has no stale pages" do
      feed.pages.each { |page| page.update(fetched_at: Time.current) }
      refresh_index

      expect(RunSession).not_to receive(:call)
      worker.perform(feed_id: feed.id)
    end

    it "does not run if the domain is full" do
      feed.domain.max_readers.times { |n| feed.domain.read_with(n.to_s) }

      expect(RunSession).not_to receive(:call)
      worker.perform(feed_id: feed.id)
    end

    context("timeout") do
      it "times out if the session runs too long" do
        allow_any_instance_of(Bellbro::Timer).to receive(:timed_out?) { true }
        expect_any_instance_of(Feed).to receive(:stop).with(timed_out: true)
        worker.perform(feed_id: feed.id)
      end
    end
  end
end
