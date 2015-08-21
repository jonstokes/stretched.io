class ExtractDocumentFromNode
  class BuildDocument
    include Troupe

    expects :page, :instance, :adapter

    provides(:document) do
      id = generate_document_id
      find_document(id) ||
        Document.new(
          id:         id,
          properties: instance,
          page_id:    page.id,
          adapter_id: adapter.id
        )
    end

    def generate_document_id
      return SecureRandom.uuid unless adapter.id_property.present?
      id_source = instance[adapter.id_property]
      return SecureRandom.uuid unless id_source.present?
      UUIDTools::UUID.parse_string("#{adapter.mapping}#{id_source}").to_s
    end

    def find_document(id)
      return unless id.present?
      doc = Document.find(id)
      doc.properties.merge!(instance)
      doc.page_id = page.id
      doc.adapter_id = adapter.id
      doc
    rescue Elasticsearch::Persistence::Repository::DocumentNotFound, Elasticsearch::Transport::Transport::Errors::NotFound
      nil
    end
  end
end
