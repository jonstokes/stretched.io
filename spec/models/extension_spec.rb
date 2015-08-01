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

  describe "::all_names" do
    it "returns an array of extension names" do
      create(:extension, name: "name-1")
      create(:extension, name: "name-2")

      expect(Extension.all_names).to eq(%w(name-1 name-2))
    end
  end
end
