require 'rails_helper'

RSpec.describe Session::Queue, type: :model do
  let(:session_queue) { create(:session_queue) }

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

  context "associations" do
    describe "sessions" do
      it "is a relation of sessions in this queue" do
        sessions = 5.times.map { create(:session, session_queue: session_queue) }
        sessions.each do |session|
          expect(session_queue.sessions).to include(session)
        end
      end
    end
  end

  context "reader tracking" do
    describe "#readers" do
      it "counts the number of readers" do
        session_queue.read!
        session_queue.read!

        expect(session_queue.readers).to eq(2)

        session_queue.stop_reading!
        expect(session_queue.readers).to eq(1)
      end
    end
  end

  context "pusing and popping" do
    describe "#push" do
      it "adds a session object to the session queue" do
        session = build(:session)
        session_queue.push(session)
        expect(session_queue.size).to eq(1)
      end

      it "adds an array of sessions" do
        sessions = 5.times.map { build(:session) }
        session_queue.push(sessions)
        expect(session_queue.size).to eq(5)
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
