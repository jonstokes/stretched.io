require 'rails_helper'

RSpec.describe Schema, type: :model do
  context "validations" do
    subject { create(:schema) }

    it { is_expected.to be_valid }

    it "requires id" do
      subject.id = nil
      expect(subject).not_to be_valid
    end

    it "requires data" do
      subject.data = nil
      expect(subject).not_to be_valid
    end

    it "requries data to be a valid v4 JSON schema" do
      subject.data = { enum: 5 }
      expect(subject).not_to be_valid
    end
  end
end
