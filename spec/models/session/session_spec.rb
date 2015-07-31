require 'rails_helper'

RSpec.describe Session, type: :model do
  context "validations" do
    subject { create(:session) }

    it { is_expected.to be_valid }

    %w(session_queue_id page_format document_adapters urls).each do |attr|
      it "requires #{attr}" do
        subject.send("#{attr}=", nil)
        expect(subject).not_to be_valid
      end
    end

    it "requires page_format to be one of :html, :xml, :dhtml" do
      subject.page_format = :test
      expect(subject).not_to be_valid
    end
  end
end
