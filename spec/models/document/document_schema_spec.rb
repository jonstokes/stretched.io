require 'rails_helper'

RSpec.describe Document::Schema, type: :model do
  context "validations" do
    subject { create(:document_schema) }

    it { is_expected.to be_valid }

    it "requires name" do
      subject.name = nil
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

  describe "#::new" do
    it "returns a new Document::Schema" do
      expect(Document::Schema.new).to be_a(Document::Schema)
    end
  end
end
