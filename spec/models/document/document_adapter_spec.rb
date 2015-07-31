require 'rails_helper'

RSpec.describe Document::Adapter, type: :model do
  context "validations" do
    subject { create(:document_adapter) }

    it { is_expected.to be_valid }

    %w(name document_schema_id document_queue_id property_queries).each do |attr|
      it "requires #{attr}" do
        subject.send("#{attr}=", nil)
        expect(subject).not_to be_valid
      end
    end
  end
end
