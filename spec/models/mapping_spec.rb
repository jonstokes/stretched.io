require 'rails_helper'

RSpec.describe Mapping, type: :model do
  context "validations" do
    subject { build(:mapping) }

    it { is_expected.to be_valid }

    it "requires id" do
      subject.id = nil
      expect(subject).not_to be_valid
    end

    it "requires data" do
      subject.data = nil
      expect(subject).not_to be_valid
    end
  end

  describe "::create" do
    it "creates a mapping for the specified doc type" do
      mapping =  create(:mapping)
      expect(Mapping.find(mapping.id)).to be_a(Mapping)
    end
  end

  describe "::all" do
    it "returns all the user-created mappings" do
      mapping1 = create(:mapping)
      mapping2 = create(:mapping)

      mappings = Mapping.all
      expect(mappings.size).to eq(2)
      expect(mappings.map(&:id)).to eq([mapping1.id, mapping2.id])
    end
  end
end
