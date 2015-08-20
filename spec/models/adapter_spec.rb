require 'rails_helper'

RSpec.describe Adapter, type: :model do
  context "validations" do
    subject { create(:adapter) }

    it { is_expected.to be_valid }

    %w(name schema_id property_setters).each do |attr|
      it "requires #{attr}" do
        subject.send("#{attr}=", nil)
        expect(subject).not_to be_valid
      end
    end
  end
end
