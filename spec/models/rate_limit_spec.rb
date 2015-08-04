require 'rails_helper'
require 'benchmark'
require 'timecop'

RSpec.describe RateLimit, type: :model do

  let(:peak_start)    { Time.parse("10:00 AM CST") }
  let(:peak_duration) { 5.hours }
  let(:peak_rate)     { 0.1 }
  let(:off_peak_rate) { 1 }
  let(:rate_limit)    {
    create(
      :rate_limit,
      peak_start:    peak_start,
      peak_duration: peak_duration,
      peak_rate:     peak_rate,
      off_peak_rate: off_peak_rate
    )
  }

  let(:peak_time)     { peak_start + 5.minutes }
  let(:off_peak_time) { peak_start + peak_duration + 5.minutes }

  context "validations" do
    subject { create(:rate_limit) }

    it { is_expected.to be_valid }

    %w(name peak_start peak_duration peak_rate off_peak_rate).each do |attr|
      it "requires #{attr}" do
        subject.send("#{attr}=", nil)
        expect(subject).not_to be_valid
      end
    end
  end

  describe "#rate" do
    it "returns the peak rate during peak hours" do
      Timecop.travel(peak_time) {
        expect(rate_limit.rate).to eq(peak_rate)
      }
    end

    it "returns the off-peak rate during off-peak hours" do
      Timecop.travel(off_peak_time) {
        expect(rate_limit.rate).to eq(off_peak_rate)
      }
    end
  end

  describe "#with_limit" do
    it "limits the rate" do
      result = Benchmark.measure {
        2.times {
          rate_limit.with_limit("www.retailer.com") do
            next # no-op
          end
        }
      }
      expect(result.real).to be > rate_limit.rate
    end
  end
end
