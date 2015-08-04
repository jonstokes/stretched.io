require 'rails_helper'

RSpec.describe Document::Document, type: :model do
  context "validations" do
    subject { create(:document) }

    it { is_expected.to be_valid }

    %w(document_adapter_id document_queue_id page_id properties).each do |attr|
      it "requires #{attr}" do
        subject.send("#{attr}=", nil)
        expect(subject).not_to be_valid
      end
    end

    it "validates properties against the adapter's schema" do
      subject.properties = { "price" => 100 }
      expect(subject).not_to be_valid
    end
  end
end
