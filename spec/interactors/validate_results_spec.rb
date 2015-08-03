require 'spec_helper'

describe ValidateResults do
  let(:instance) {
    {
      'title' => 'Page 1',
      'price_in_cents' => 'invalid',
      'unknown_attribute' => 100
    }
  }
  let(:adapter) { create(:document_adapter) }

  describe "#call" do
    it "includes only valid key/value pairs in the instance hash" do
      result = ValidateResults.call(instance: instance, adapter: adapter)
      expect(result.instance).to eq({'title' => 'Page 1'})
    end
  end
end