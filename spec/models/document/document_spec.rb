require 'rails_helper'

RSpec.describe Document::Document, type: :model do
  subject { create(:document) }

  context "validations" do
    it { is_expected.to be_valid }

    it "requires a session_reader" do
      subject.session_reader = nil
      expect { subject.validate }.to raise_error(NoMethodError)
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

  context "attributes" do
    it "has a session" do
      expect(subject.session).not_to be_nil
    end

    it "has an adapter" do
      expect(subject.adapter)
    end
  end
end
