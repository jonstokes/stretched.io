require 'rails_helper'

RSpec.describe RateLimit, type: :model do
  context "validations" do
    subject { create(:rate_limit) }

    it { is_expected.to be_valid }

    %w(peak_start peak_duration peak_rate off_peak_rate).each do |attr|
      it "requires #{attr}" do
        subject.send("#{attr}=", nil)
        expect(subject).not_to be_valid
      end
    end
  end
end
