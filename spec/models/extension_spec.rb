require 'rails_helper'

RSpec.describe Extension, type: :model do
  context "validations" do
    subject { create(:extension) }

    it { is_expected.to be_valid }

    it "requires name" do
      subject.name = nil
      expect(subject).not_to be_valid
    end

    it "requires source" do
      subject.source = nil
      expect(subject).not_to be_valid
    end
  end
end
