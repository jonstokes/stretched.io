require 'rails_helper'

RSpec.describe Session::Queue, type: :model do
  context "validations" do
    subject { create(:session_queue) }

    it { is_expected.to be_valid }

    %w(name max_size rate_limit_id).each do |attr|
      it "requires #{attr}" do
        subject.send("#{attr}=", nil)
        expect(subject).not_to be_valid
      end
    end

    it "requires max_size to be greater than zero" do
      subject.max_size = 0
      expect(subject).not_to be_valid
    end
  end
end
