require 'rails_helper'

RSpec.describe Session::Queue, type: :model do
  context "validations" do
    subject { create(:session_queue) }

    it { is_expected.to be_valid }

    %w(name max_size rate_limit_id).each do |attr|
      it "requires #{attr}" do
        subject.send("#{attr}=", nil)
        expect(subject).not_to be_valid
      end
    end

    it "requires max_size to be greater than zero" do
      subject.max_size = 0
      expect(subject).not_to be_valid
    end
  end

  context "pusing and popping" do
    let(:session_queue) { create(:session_queue) }
    
    describe "#push" do
      it "adds a session object to the session queue" do
        session = build(:session)
        session_queue.push(session)
        expect(session_queue.size).to eq(1)
      end
    end

    describe "#pop" do
      it "removes a session from the queue" do
        session = build(:session)
        session_queue.push(session)

        ssn = session_queue.pop
        expect(ssn).to be_a(Session::Session)
        expect(ssn).not_to be_persisted
      end
    end
  end
end
