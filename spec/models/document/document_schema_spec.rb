require 'rails_helper'

RSpec.describe Document::Schema, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"

  describe "#::new" do
    it "returns a new Document::Schema" do
      expect(Document::Schema.new).to be_a(Document::Schema)
    end
  end
end
