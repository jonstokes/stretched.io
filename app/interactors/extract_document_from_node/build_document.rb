class ExtractDocumentFromNode
  class BuildDocument
    include Troupe

    expects :page, :instance, :adapter

    provides(:document) do
      found_document ||
        Document.new(
          id:         generate_document_id,
          properties: instance,
          page_id:    page.id,
          adapter_id: adapter.id
        )
    end

    def generate_document_id
      return SecureRandom.uuid unless adapter.id_property.present?
      id_source = instance[adapter.id_property]
      return SecureRandom.uuid unless id_source.present?
      UUIDTools::UUID.parse_string(id_source)
    end

    def found_document
      return unless id = instance['id']
      doc = Document.find(id)
      doc.properties.merge!(instance)
      doc.page_id = page.id
      doc.adapter_id = adapter.id
    rescue Elasticsearch::Persistence::Repository::DocumentNotFound
      nil
    end
  end
end
