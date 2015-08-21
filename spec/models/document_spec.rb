require 'rails_helper'

RSpec.describe Document, type: :model do
  subject { create(:document) }

  context "validations" do
    it { is_expected.to be_valid }

    it "requries a page_id" do
      subject.page_id = nil
      expect(subject).not_to be_valid
    end

    it "requires an adapter_id" do
      subject.adapter_id = nil
      expect(subject).not_to be_valid
    end

    it "requires properties" do
      subject.properties = nil
      expect(subject).not_to be_valid
    end

    it "validates properties against the adapter's schema" do
      subject.properties = { "price" => 100 }
      expect(subject).not_to be_valid
      expect(subject.errors.messages[:properties].first).to include("The property '#/' did not contain a required property of 'title' in schema")
    end
  end

  context "persistence" do
    let(:properties) { {title: 'Title', price: 100} }
    let(:document)   {
      build(
        :document,
        properties: properties
      )
    }

    describe "#save" do
      it "saves to the index with the given mapping" do
        document.save
        refresh_index
        response = Index.client.search(
          index: Index.name,
          type:  document.mapping,
          body: {
            query: {
              match_all: {}
            }
          }
        )
        doc = response['hits']['hits'].first
        expect(doc['_id']).to eq(document.id)
        expect(doc['_source']['title']).to eq(document.properties[:title])
        expect(doc['_source']['price']).to eq(document.properties[:price])
        expect(doc['_source']['page_id']).to eq(document.page_id)
        expect(doc['_source']['adapter_id']).to eq(document.adapter_id)
      end
    end

    describe "::all" do
      it "returns an array of all the dynamically created documents" do
        3.times { create(:document, properties: properties) }
        refresh_index
        documents = Document.all
        expect(documents.size).to eq(3)
        doc = documents.first
        expect(doc.properties).to eq(properties.stringify_keys)
      end

      it "returns an empty array if there are no documents" do
        expect(Document.all).to eq([])
      end
    end

    describe "::each" do
      it "iterates through all the dynamically created documents" do
        3.times { create(:document, properties: properties) }
        refresh_index
        Document.each do |doc|
          expect(doc).to be_a(Document)
        end
      end

      it "does nothing if there are no documents" do
        expect { Document.each {} }.not_to raise_error
      end
    end

    describe "::find" do
      it "locates the document by mapping and id and returns a Document" do
        document.save
        refresh_index
        doc = Document.find(document.id)
        expect(doc).to be_a(Document)
        expect(doc.properties).to eq(document.properties.stringify_keys)
        expect(doc.persisted?).to eq(true)
        expect(doc.version).to eq(1)
      end
    end
  end
end
