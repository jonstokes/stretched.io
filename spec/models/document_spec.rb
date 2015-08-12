require 'rails_helper'

RSpec.describe Document, type: :model do
  subject { create(:document) }

  context "validations" do
    it { is_expected.to be_valid }

    it "requries a page_id" do
      subject.page_id = nil
      expect(subject).not_to be_valid
    end

    it "requires an adapter_id" do
      subject.adapter_id = nil
      expect(subject).not_to be_valid
    end

    it "requires properties" do
      subject.properties = nil
      expect(subject).not_to be_valid
    end

    it "validates properties against the adapter's schema" do
      subject.properties = { "price" => 100 }
      expect(subject).not_to be_valid
      expect(subject.errors.messages[:properties].first).to include("The property '#/' did not contain a required property of 'title' in schema")
    end
  end
end
