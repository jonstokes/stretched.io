require 'rails_helper'

RSpec.describe Page, type: :model do
  context "validations" do
    subject { create(:page) }

    it { is_expected.to be_valid }

    %w(url code response_time headers).each do |attr|
      it "requires #{attr}" do
        subject.send("#{attr}=", nil)
        expect(subject).not_to be_valid
      end
    end

    it "requires a valid url" do
      subject.url = "test"
      expect(subject).not_to be_valid
    end

    it "requires a status code that's in range" do
      subject.code = 1
      expect(subject).not_to be_valid
    end
  end
end
