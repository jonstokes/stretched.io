class ExtractDocumentFromNode
  class BuildDocument
    include Troupe

    expects :page, :instance, :adapter

    provides(:document) do
      found_document ||
        Document.new(
          properties: instance,
          page_id:    page.id,
          adapter_id: adapter.id
        )
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
