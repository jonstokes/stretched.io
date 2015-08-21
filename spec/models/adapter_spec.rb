require 'rails_helper'

RSpec.describe Adapter, type: :model do
  context "validations" do
    subject { create(:adapter) }

    it { is_expected.to be_valid }

    %w(name schema_name property_setters).each do |attr|
      it "requires #{attr}" do
        subject.send("#{attr}=", nil)
        expect(subject).not_to be_valid
      end
    end
  end

  context "persistence" do
    it "serializes the property setters with YAML to preserve Ruby object types" do
      create(
        :adapter,
        property_setters: {
          title: [
            {
              find_by_xpath: {
                xpath: "//title",
                pattern: /title/i
              }
            }
          ]
        }
      )
      refresh_index
      adapter = Adapter.all.first
      expect(adapter.property_setters[:title].first[:find_by_xpath][:pattern]).to be_a(Regexp)
    end
  end
end
